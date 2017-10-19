//
//  PostApi.swift
//  GymMe
//
//  Created by Eno Reyes on 7/11/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation
import FirebaseDatabase

class HashtagApi {
    
    var REF_HASHTAG = Database.database().reference().child("hashtags")
    
    func fetchPosts(withTag tag: String, completion: @escaping (String) -> Void) {
        REF_HASHTAG.child(tag.lowercased()).observe(.childAdded, with: {
            snapshot in
            
            completion(snapshot.key)
        })
    }
}
