//
//  Post.swift
//  GymMe
//
//  Created by Eno Reyes on 7/14/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation
import FirebaseAuth

class Notification {

    var from: String?
    var objectId: String?
    var type: String?
    var timestamp: Int?
    var id: String?
    
}

extension Notification {
    static func transform(dict: [String: Any], key: String) -> Notification {
        
        let notification = Notification()
        notification.id = key
        notification.objectId = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        notification.from = dict["from"] as? String
        
        return notification
    }
}
