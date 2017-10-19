//
//  PostApi.swift
//  GymMe
//
//  Created by Eno Reyes on 7/14/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NotificationApi {
    
    var REF_NOTIFICATION = Database.database().reference().child("notification")
    
    func observeNotification(withId id: String, completion: @escaping (Notification) -> Void) {
        REF_NOTIFICATION.child(id).observe(.childAdded, with: {
            snapshot in

            if let dict = snapshot.value as? [String: Any]
                {
                let newNotification = Notification.transform(dict: dict, key: snapshot.key)
                completion(newNotification)
            }
            
        })
    }
}
