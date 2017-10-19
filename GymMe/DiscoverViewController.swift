//
//  DiscoverViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 7/1/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var posts: [Post] = []
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
    let myArray: NSArray = ["Run","Arms","Chest", "Biceps", "Cardio", "Inspiration"]
    var myTableView: UITableView!
    var currIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.tintColor = Config.GYM_RED
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Config.GYM_RED]
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadTopPosts()
    }

    func loadTopPosts() {
        ProgressHUD.show("Loading...", interaction: false)
        self.posts.removeAll()
        self.collectionView.reloadData()
        Api.Post.observeTopPosts { (post) in
            
            if post.isTextPost == false {
            
            self.posts.append(post)
            self.collectionView.reloadData()
            
            }
            
            ProgressHUD.dismiss()
        }
    }
    
    func clearPosts() {
        ProgressHUD.show("Loading...", interaction: false)
        self.posts.removeAll()
        self.collectionView.reloadData()
        ProgressHUD.dismiss()
    }
    
    func loadCategories() {
        
    }

    @IBAction func refreshTouchUpInside(_ sender: Any) {
        loadTopPosts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Discover_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
        
        if segue.identifier == "Discover_HashtagSegue" {
            let hashtagVC = segue.destination as! HashtagViewController
            let tag = sender as! String
            hashtagVC.tag = tag
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        
        if currIndex == 2 {
            self.myTableView.removeFromSuperview()
            self.collectionView.isHidden = false
        }
        
        switch segmentControl.selectedSegmentIndex
        {
            
        case 0:
            loadTopPosts()
            currIndex = 0
        case 1:
            clearPosts()
            currIndex = 1
        case 2:
            addTableView()
            currIndex = 2
        default:
            break; 
        }
        
    }
    

}

extension DiscoverViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        
        return cell
    }
}

extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
}

extension DiscoverViewController: PhotoCollectionViewCellDelegate {
 
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Discover_DetailSegue", sender: postId)
    }
    
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "Discover_HashtagSegue", sender: tag)
    }
}



extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    
    func addTableView() {

        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
 
        self.contentView.addSubview(myTableView)
        
        self.collectionView.isHidden = true
    }
    
    func removeTableView() {
        self.view.willRemoveSubview(myTableView)
        self.collectionView.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(myArray[indexPath.row])")
        
        let word = myArray[indexPath.row] as! String
        goToHashtag(tag: word.lowercased())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(myArray[indexPath.row])"
        return cell
    }
}

