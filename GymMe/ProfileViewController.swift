//
//  ProfileViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 7/1/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var user: UserModel!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.tintColor = Config.GYM_RED
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Config.GYM_RED]

        //remove nav bar shadow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        
        fetchUser()
        fetchMyPosts()
    }

    func fetchUser() {
        
        Api.User.observeCurrentUser { (user) in
            
            self.user = user
            //self.navigationItem.title = user.username
            let  headerCell = self.tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! ProfileHeaderTableViewCell
            headerCell.user = user
            headerCell.updateView()
            headerCell.delegate2 = self
            self.tableView.tableHeaderView = headerCell
            self.tableView.reloadData()
        }
    }
    
    func fetchMyPosts() {
        
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        Api.MyPosts.REF_MY_POSTS.child(currentUser.uid).observe(.childAdded, with: {
            snapshot in
            
            Api.Post.observePost(withId: snapshot.key, completion: {
                post in
                self.posts.append(post)
                self.tableView.reloadData()
            })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile_SettingSegue" {
            let settingVC = segue.destination as! SettingTableViewController
            settingVC.delegate = self
        }
        
        if segue.identifier == "Profile_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
        
        if segue.identifier == "commentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Home_HashtagSegue" {
            let hashtagVC = segue.destination as! HashtagViewController
            let tag = sender as! String
            hashtagVC.tag = tag
        }

    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        
        let post = posts[indexPath.row]
        cell.post = post
        cell.isInUserProfile = true
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension ProfileViewController: HomeTableViewCellDelegate {
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


extension ProfileViewController: HeaderProfileReusableViewDelegateSwitchSettingVC {
    func goToSettingVC() {
        performSegue(withIdentifier: "Profile_SettingSegue", sender: nil)
    }
}

extension ProfileViewController: SettingTableViewControllerDelegate {
    func updateUserInfo() {
        self.fetchUser()
    }
}

