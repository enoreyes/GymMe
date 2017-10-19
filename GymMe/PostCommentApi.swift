//
//  PostApi.swift
//  GymMe
//
//  Created by Eno Reyes on 7/3/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PostCommentApi {
    
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
    
    func observeCommentsCount(withPostId id: String, completion: @escaping (Int) -> Void) {
        
        REF_POST_COMMENTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            
            if let data = snapshot as? DataSnapshot {
                completion(Int(data.childrenCount))
            }
            
        })
        
    }
}
