//
//  DetailViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 7/23/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var postId = ""
    var post = Post()
    var user = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadPost()
    }

    func loadPost() {
        Api.Post.observePost(withId: postId) { (post) in
            guard let postUid = post.uid else {
                return
            }
            
            self.fetchUser(uid: postUid, completed: {
                self.post = post
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        
        Api.User.observeUser(withId: uid, completion: {
            
            user in
            self.user = user
            completed()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail_CommentVC" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Detail_ProfileUserSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Detail_HashtagSegue" {
            let hashtagVC = segue.destination as! HashtagViewController
            let tag = sender as! String
            hashtagVC.tag = tag
        }
    }
}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell

        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
        
    }
}

extension DetailViewController: HomeTableViewCellDelegate {
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "Detail_CommentVC", sender: postId)
    }
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Detail_ProfileUserSegue", sender: userId)
    }
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "Detail_HashtagSegue", sender: tag)
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
