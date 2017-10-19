//
//  CommentTableViewCell.swift
//  GymMe
//
//  Created by Eno Reyes on 7/2/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit
import KILabel

protocol CommentTableViewCellDelegate {
    func goToProfileUserVC(userId: String)
    func goToHashtag(tag: String)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: KILabel!
    
    var delegate: CommentTableViewCellDelegate?
    
    var comment: Comment? {
        didSet {
            updateView()
        }
    }
    
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    func updateView() {
        commentLabel.text = comment?.commentText
        
        commentLabel.hashtagLinkTapHandler = { label, string, range in
            let tag = String(string.characters.dropFirst())
            self.delegate?.goToHashtag(tag: tag)
        }
        
        commentLabel.userHandleLinkTapHandler = { label, string, range in
            let mention = String(string.characters.dropFirst())
            
            Api.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user.id!)
            })
        }
    }
    
    func setupUserInfo() {
        nameLabel.text = user?.username
        
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string:photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named:"placeholder-photo"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.text = ""
        commentLabel.text = ""
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabelTouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
    }
    
    @objc func nameLabelTouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "placeholder-photo")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
