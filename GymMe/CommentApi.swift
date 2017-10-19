//
//  PostApi.swift
//  GymMe
//
//  Created by Eno Reyes on 7/3/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CommentApi {
    
    var REF_COMMENTS = Database.database().reference().child("comments")
    
    func observeComments(withPostId id: String, completion: @escaping (Comment) -> Void) {
        
        REF_COMMENTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            
            if let postDict = snapshot.value as? [String: Any] {
                
                let newComment = Comment.transformComment(dict: postDict)
                
                completion(newComment)
                
            }
        })
        
    }
    
}
