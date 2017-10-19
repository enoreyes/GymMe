//
//  Post.swift
//  GymMe
//
//  Created by Eno Reyes on 7/2/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation

class Comment {
    var commentText: String?
    var uid: String?
}

extension Comment {
    static func transformComment(dict: [String: Any]) -> Comment {
        
        
        
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid =  dict["uid"] as? String

        return comment
    }
}
