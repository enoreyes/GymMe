//
//  HomeTableViewCell.swift
//  GymMe
//
//  Created by Eno Reyes on 7/2/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit
import AVFoundation
import KILabel

protocol HomeTableViewCellDelegate {
    func goToCommentVC(postId: String)
    func goToProfileUserVC(userId: String)
    func goToHashtag(tag: String)
    func presentSocialOptions(content: [Any])
}


class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: KILabel!
    @IBOutlet weak var cellFrame: UIView!
    @IBOutlet weak var heightConstraintPhoto: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var volumeVIew: UIView!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var commentCountButton: UIButton!
    
    var delegate: HomeTableViewCellDelegate?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isInUserProfile: Bool?
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    var isMuted = true
    
    func updateView() {

        captionLabel.text = post?.caption
        locationNameLabel.text = post?.locationName
        
        captionLabel.hashtagLinkTapHandler = { label, string, range in
            let tag = String(string.characters.dropFirst())
            self.delegate?.goToHashtag(tag: tag)
        }
        
        if let id = post?.id {   
            Api.PostComment.observeCommentsCount(withPostId: id, completion: { (count) in
                self.commentCountButton.setTitle("\(count)", for: .normal)
                print(count)
                })
        }
        
        
        captionLabel.userHandleLinkTapHandler = { label, string, range in
            let mention = String(string.characters.dropFirst())
            
            Api.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user.id!)
            })
        }
        
        // IMPLEMENT COMMENT API COUNT FUNCTION HERE
        
        if let isTextPost = post?.isTextPost {
            
            if isTextPost {
                heightConstraintPhoto.constant = 1
                layoutIfNeeded()
            } else {
                if let ratio = post?.ratio {
                    if ratio > 0.75 {
                    heightConstraintPhoto.constant = 335 / ratio
                    layoutIfNeeded()
                    }
                }
            }
        }
        
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string:photoUrlString)
            postImageView.sd_setImage(with: photoUrl)
        }
        
        if let videoUrlString = post?.videoUrl, let videoUrl = URL(string:videoUrlString) {
            
            self.volumeVIew.isHidden = false
            player = AVPlayer(url: videoUrl)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = postImageView.frame
            playerLayer?.frame.size.width = 335
            self.contentView.layer.addSublayer(playerLayer!)
            self.volumeVIew.layer.zPosition = 1
            
            player?.play()
            player?.isMuted = isMuted
        }
        
        //add shadow
        cellFrame.layer.shadowOpacity = 0.2
        cellFrame.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
        cellFrame.layer.shadowRadius = 2.0
        
        if let timestamp = post?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            
            if diff.second! <= 0 {
                timeText = "Now"
            }
            
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = (diff.second == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
            }
            
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = (diff.minute == 1) ? "\(diff.minute!) minute ago" : "\(diff.minute!) minutes ago"
            }
            
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = (diff.hour == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
            }
            
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = (diff.day == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
            }
            
            if diff.weekOfMonth! > 0 {
                timeText = (diff.weekOfMonth == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
            }
            
            timeLabel.text = timeText
        }
        
        //Smoothly update likes (taking into account cell reuse)
        self.updateLike(post: self.post!)
    }
    
    func updateLike(post: Post) {
        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        likeImageView.image = UIImage(named: imageName)
        
        guard let count = post.likeCount else {
            return
        }
        
        if count != 0 {
            likeCountButton.setTitle("\(count)", for: UIControlState.normal)
        } else {
            likeCountButton.setTitle("0", for: UIControlState.normal)
        }
    
    }
    
    @IBAction func volumeButtonTouchUpInside(_ sender: UIButton) {
        if isMuted {
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "Icon_Volume"), for: .normal)
        } else {
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "Icon_Mute"), for: .normal)
        }
        player?.isMuted = isMuted
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
        captionLabel.text = ""
        
        //for comment button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageViewTouchUpInside))
        commentImageView.addGestureRecognizer(tapGesture)
        commentImageView.isUserInteractionEnabled = true
        
        //for like button
        let tapGestureForLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.likeImageViewTouchUpInside))
        likeImageView.addGestureRecognizer(tapGestureForLikeImageView)
        likeImageView.isUserInteractionEnabled = true
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabelTouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
        
        //for share button
        let tapGestureForShareImageView = UITapGestureRecognizer(target: self, action: #selector(self.shareImageViewTouchUpInside))
        shareImageView.addGestureRecognizer(tapGestureForShareImageView)
        shareImageView.isUserInteractionEnabled = true
    }
    
    @objc func shareImageViewTouchUpInside() {
        
        let captionText = captionLabel.text!
        let message = "Download GymMe to see this photo and more *insert link* " + captionText
        print(message)
        var objectsToShare = [message] as? [Any]
        
        if let imageToShare = postImageView.image {
            objectsToShare?.insert(imageToShare, at: 1)
        }
        
        self.delegate?.presentSocialOptions(content: objectsToShare!)
    }
    
    @objc func nameLabelTouchUpInside() {
        if let id = user?.id {
            if isInUserProfile != true {
            delegate?.goToProfileUserVC(userId: id)
            }
        }
    }
    
    @objc func likeImageViewTouchUpInside() {
        
        Api.Post.incrementLikes(postId: post!.id!, onSuccess: { (post) in
            self.updateLike(post: post)
            self.post?.likes = post.likes
            self.post?.isLiked = post.isLiked
            self.post?.likeCount = post.likeCount
            
            if post.uid != Api.User.CURRENT_USER?.uid {
                let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                
                if post.isLiked! {
                    let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(post.uid!).child("\(post.id!)-\(Api.User.CURRENT_USER!.uid)")
                    newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "objectId": post.id!, "type": "like", "timestamp": timestamp])
                } else {
                    let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(post.uid!).child("\(post.id!)-\(Api.User.CURRENT_USER!.uid)")
                    newNotificationReference.removeValue()
                }
                
            }
            
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
        //incrementLikes(forRef: postRef)
        
    }
        
    @objc func commentImageViewTouchUpInside() {
        
        if let id = post?.id {
            delegate?.goToCommentVC(postId: id)
        }
        
    }
    
    //clean a cell for reuse in the feed
    override func prepareForReuse() {
        super.prepareForReuse()

        heightConstraintPhoto.constant = 335
        profileImageView.image = UIImage(named: "placeholder-photo")
        likeCountButton.setTitle("0", for: .normal)
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        volumeVIew.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
