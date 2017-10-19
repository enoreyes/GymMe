//
//  AuthService.swift
//  GymMe
//
//  Created by Eno Reyes on 7/2/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

class HelperService {

    static func uploadDataToServer(data: Data, ratio: CGFloat, videoUrl: URL? = nil, caption: String, isTextPost: Bool, lat: Double, long: Double, locationName: String, onSuccess: @escaping () -> Void) {
        if let videoUrl = videoUrl {
            uploadVideoToFirebaseStorage(videoUrl: videoUrl, onSuccess: { (videoUrl) in
                uploadImageToFirebaseStorage(data: data, onSuccess: {
                    (thumbnailImageUrl) in
                    
                    sendDataToDatabase(photoUrl: thumbnailImageUrl, ratio: ratio, videoUrl: videoUrl, caption: caption, isTextPost: isTextPost, locationName: locationName, lat: lat, long: long, onSuccess: onSuccess)
                })
            })
            //
        } else if isTextPost {
            
            sendDataToDatabase(photoUrl: "nil", ratio: 1, caption: caption, isTextPost: isTextPost, locationName: locationName, lat: lat, long: long, onSuccess: onSuccess)
            
        }
        
        else {
              self.uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, caption: caption, isTextPost: isTextPost, locationName: locationName, lat: lat, long: long, onSuccess: onSuccess)

            }
        }
    }
    
    static func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping (_ videoUrl: String) -> Void) {
        let videoIdString = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(videoIdString)
        
        storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                onSuccess(videoUrl)
            }
        }
    }
    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
        
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let photoUrl = metadata?.downloadURL()?.absoluteString {
                onSuccess(photoUrl)
            }
        }
    }
    
    static func sendDataToDatabase(photoUrl: String, ratio: CGFloat, videoUrl: String? = nil, caption: String, isTextPost: Bool, locationName: String,  lat: Double, long: Double, onSuccess: @escaping () -> Void) {
        
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key
        let newPostReference = Api.Post.REF_POSTS.child(newPostId)
        
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        
        let currentUserId = currentUser.uid
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                if word.characters.count >= 2 {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashTagRef = Api.Hashtag.REF_HASHTAG.child(word.lowercased())
                newHashTagRef.updateChildValues([newPostId: true])
                }
            }
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var dict = ["uid": currentUserId, "photoUrl": photoUrl, "caption": caption, "likeCount": 0, "locationName": locationName, "ratio": ratio, "timestamp": timestamp, "isTextPost": isTextPost, "lat": lat, "long": long] as [String : Any]
        if let videoUrl = videoUrl {
            dict["videoUrl"] = videoUrl
        }
        
        newPostReference.setValue(dict, withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            //tag user to post
            let myPostRef = Api.MyPosts.REF_MY_POSTS.child(currentUserId).child(newPostId)
            
            myPostRef.setValue(["timestamp": timestamp], withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                
            Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(newPostId).setValue(["timestamp": timestamp])
                Api.Follow.REF_FOLLOWERS.child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
                    snapshot in
                    let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                    arraySnapshot.forEach( { (child) in
                        
                        Api.Feed.REF_FEED.child(child.key).child(newPostId).setValue(["timestamp": timestamp])
                        
                        let newNotificationId = Api.Notification.REF_NOTIFICATION.child(child.key).childByAutoId().key
                        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(child.key).child(newNotificationId)
                        
                        newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "type": "newPost", "objectId": newPostId, "timestamp": timestamp])
                    })
                })
                
            })
            ProgressHUD.showSuccess("Success")
            onSuccess()
        })
    }
    
}
