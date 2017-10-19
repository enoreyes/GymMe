//
//  Post.swift
//  GymMe
//
//  Created by Eno Reyes on 7/2/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation
import FirebaseAuth

class Post {
    var caption: String?
    var photoUrl: String?
    var uid: String?
    var id: String?
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
    var ratio: CGFloat?
    var videoUrl: String?
    var timestamp: Int?
    var isTextPost: Bool?
    var lat: Int?
    var long: Int?
    var locationName: String?
}

extension Post {
    static func transformPostPhoto(dict: [String: Any], key: String) -> Post {
        
        let post = Post()
        post.id = key
        post.caption = dict["caption"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.videoUrl = dict["videoUrl"] as? String
        post.uid =  dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        post.ratio = dict["ratio"] as? CGFloat
        post.timestamp = dict["timestamp"] as? Int
        post.isTextPost = dict["isTextPost"] as? Bool
        post.lat = dict["lat"] as? Int
        post.long = dict["long"] as? Int
        post.locationName = dict["locationName"] as? String
        
        if let currentUserId = Auth.auth().currentUser?.uid {
            
        //compares to see if current user is in the posts likes array
        if post.likes != nil {
            post.isLiked = post.likes?[currentUserId] != nil
        }
            
        }
        return post
    }
}
