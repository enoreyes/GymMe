//
//  Post.swift
//  GymMe
//
//  Created by Eno Reyes on 7/2/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation

class UserModel {
    var email: String?
    var profileImageUrl: String?
    var username: String?
    var id: String?
    var isFollowing: Bool?
    var isVerified: Bool?
    var description: String?
}

extension UserModel {
    static func transformUser(dict: [String: Any], key: String) -> UserModel {
        
        let user = UserModel()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username =  dict["username"] as? String
        user.description = dict["description"] as? String
        user.id = key
        return user
    }
}
