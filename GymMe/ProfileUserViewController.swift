//
//  ProfileUserViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 7/9/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

class ProfileUserViewController: UIViewController {
    
    var user: UserModel!
    var posts: [Post] = []
    
    var userId = ""
    var delegate: HeaderProfileReusableViewDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUser()
        fetchMyPosts()
    }


    func fetchUser() {
        
        Api.User.observeUser(withId: userId) { (user) in
            self.isFollowing(userId: user.id!, completed: {
                (value) in
                
                user.isFollowing = value
                self.user = user
                //self.navigationItem.title = user.username
                self.collectionView.reloadData()
            })
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        Api.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    func fetchMyPosts() {
        
        Api.MyPosts.fetchMyPosts(userId: userId) { (key) in
            Api.Post.observePost(withId: key, completion: {
                post in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ProfileUser_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
}


extension ProfileUserViewController: HeaderProfileReusableViewDelegateSwitchSettingVC {
    func goToSettingVC() {
        performSegue(withIdentifier: "ProfileUser_SettingSegue", sender: nil)
    }
}

extension ProfileUserViewController: UICollectionViewDelegateFlowLayout {
    
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

extension ProfileUserViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "ProfileUser_DetailSegue", sender: postId)
    }
}

