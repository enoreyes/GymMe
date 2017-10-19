//
//  HomeViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 7/1/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit
import SDWebImage
import ESPullToRefresh

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    var posts = [Post]()
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.tabBarController?.tabBar.tintColor = Config.GYM_RED
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Config.GYM_RED]
                
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        loadPosts()
        checkIfEmpty()
        
        
        self.tableView.es_addPullToRefresh {
            [weak self] in
            /// Do anything you want...
            self?.tableView.reloadData()
            /// Stop refresh when your job finished, it will reset refresh footer if completion is true
            self?.tableView.es_stopPullToRefresh(ignoreDate: true)
            /// Set ignore footer or not
            self?.tableView.es_stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
        }
        
    }
    
    func loadPosts() {
        activityIndicatorView.startAnimating()
        
        Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid) {
            (post) in
            guard let postUid = post.uid else {
                return
            }
            
            self.fetchUser(uid: postUid, completed: {
                self.posts.insert(post, at: 0)
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
            })
        }
        
        Api.Feed.observeFeedRemoved(withId: Api.User.CURRENT_USER!.uid) { (post) in
            self.posts = self.posts.filter { $0.id != post.id } // throws away post if id is not equal to key
            self.users = self.users.filter { $0.id != post.uid }
            self.tableView.reloadData()
        }
    
    }
    
    func checkIfEmpty() {
        if posts.count == 0 {
            activityIndicatorView.stopAnimating()
        }
    }
    
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        
        Api.User.observeUser(withId: uid, completion: {
            
            user in
            self.users.insert(user, at: 0)
            completed()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Home_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Home_HashtagSegue" {
            let hashtagVC = segue.destination as! HashtagViewController
            let tag = sender as! String
            hashtagVC.tag = tag
        }
    }
    
    
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "commentSegue", sender: postId)
    }
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "Home_HashtagSegue", sender: tag)
    }
    func presentSocialOptions(content: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: content, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        // activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}
