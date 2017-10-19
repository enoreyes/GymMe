//
//  PeopleTableViewCell.swift
//  GymMe
//
//  Created by Eno Reyes on 7/8/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

protocol PeopleTableViewCellDelegate {
    func goToProfileUserVC(userId: String)
}

class PeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: PeopleTableViewCellDelegate?
    
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        nameLabel.text = user?.username
        
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string:photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named:"placeholder-photo"))
        }

        
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
    
    @objc func followAction() {
        
        if user!.isFollowing! == false {
            Api.Follow.followAction(withUser: user!.id!)
            configureUnfollowButton()
            user!.isFollowing! = true
        }
    }
    
    @objc func unfollowAction() {
        if user!.isFollowing == true {
        Api.Follow.unfollowAction(withUser: user!.id!)
        configureFollowButton()
            user!.isFollowing = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.nameLabelTouchUpInside))
        nameLabel.addGestureRecognizer(tapGesture)
        nameLabel.isUserInteractionEnabled = true
    }
    
    @objc func nameLabelTouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
