//
//  HeaderProfileCollectionReusableView.swift
//  GymMe
//
//  Created by Eno Reyes on 7/3/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit


protocol HeaderProfileCollectionReusableViewDelegateSwitchSettingVC {
    func goToSettingVC()
}

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followCountLabel: UILabel!
    @IBOutlet weak var myPostCountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profilePicShadow: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    var delegate2: HeaderProfileCollectionReusableViewDelegateSwitchSettingVC?
    
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    @IBOutlet weak var profileImage: UIImageView!
    func updateView() {
        
            self.nameLabel.text = user?.username
            if let photoUrlString = user?.profileImageUrl {
                let photoUrl = URL(string:photoUrlString)
                self.profileImage.sd_setImage(with: photoUrl)
                //profilePicShadow.layer.shadowOpacity = 0.2
                //profilePicShadow.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
                //profilePicShadow.layer.shadowRadius = 2.0
        }
        
        Api.MyPosts.fetchCountMyPosts(userId: user!.id!) { (count) in
                self.myPostCountLabel.text = "\(count)"
        }
        
        Api.Follow.fetchCountFollowing(userId: user!.id!) { (count) in
            self.followCountLabel.text = "\(count)"
        }
        
        Api.Follow.fetchCountFollower(userId: user!.id!) { (count) in
            self.followerCountLabel.text = "\(count)"
        }
        
        descriptionTextView.text = user?.description
        
        if user?.id == Api.User.CURRENT_USER?.uid {
            followButton.setTitle("Edit Profile", for: .normal)
            
            followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControlEvents.touchUpInside)

        } else {
            updateStateFollowButton()
        }
        
    }
    
    func clear() {
        self.nameLabel.text = ""
        self.myPostCountLabel.text = ""
        self.followerCountLabel.text = ""
        self.followCountLabel.text = ""
    }
    
    func goToSettingVC() {
        delegate2?.goToSettingVC()
    }
    
    func updateStateFollowButton() {
        if user!.isFollowing! == true {
            configureUnfollowButton()
        } else {
            configureFollowButton()
        }
    }
    
    func configureFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.white, for: .normal)
        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        
        self.followButton.setTitle("Follow", for: .normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    
    func configureUnfollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.black, for: .normal)
        followButton.backgroundColor = UIColor.clear
        
        self.followButton.setTitle("Following", for: .normal)
        followButton.addTarget(self, action: #selector(self.unfollowAction), for: UIControlEvents.touchUpInside)
    }
    
    func followAction() {
        
        if user!.isFollowing! == false {
            Api.Follow.followAction(withUser: user!.id!)
            configureUnfollowButton()
            user!.isFollowing! = true
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    func unfollowAction() {
        if user!.isFollowing == true {
            Api.Follow.unfollowAction(withUser: user!.id!)
            configureFollowButton()
            user!.isFollowing = false
            delegate?.updateFollowButton(forUser: user!)
        }
    }
}
