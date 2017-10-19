//
//  AuthService.swift
//  GymMe
//
//  Created by Eno Reyes on 7/2/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AuthService {
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            onSuccess()
        }
        
    }
    
    static func signUp(email: String, username: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
        
        
            let uid = user?.uid
            
            //storing profile pic (UIImageRepresentation changes the storage size)
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
            
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    
                    return
                }
                
                let profileImageUrl = metadata?.downloadURL()?.absoluteString
                
                self.setUserInformation(profileImageURL: profileImageUrl!, username: username, email: email, uid: uid!, description: "", onSuccess: onSuccess)
            })
            
            
        })
        
    
    
    }
    
    static func setUserInformation(profileImageURL: String, username: String, email: String, uid: String, description: String, onSuccess: @escaping () -> Void) {
        
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        
        newUserReference.setValue(["username": username, "username_lowercase": username.lowercased(), "email": email, "description": description, "profileImageUrl": profileImageURL, "isVerified": false])
        onSuccess()
    }
    
    static func updateUserInfo(email: String, username: String, description: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        Api.User.CURRENT_USER?.updateEmail(to: email, completion: {
            (error) in
            
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                let uid = Api.User.CURRENT_USER?.uid
                
                //storing profile pic (UIImageRepresentation changes the storage size)
                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
                
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        
                        return
                    }
                    
                    let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    
                    self.updateDatabase(profileImageURL: profileImageUrl!, username: username, email: email, description: description, onSuccess: onSuccess, onError: onError)
                    
                })
            }
        })
        
    }
    
    static func sendVerificationEmail(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
        }
    }
    
    static func sendForgotPasswordEmail(email: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
        }
    }
    
    static func updateDatabase(profileImageURL: String, username: String, email: String, description: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        let dict = ["username": username, "username_lowercase": username.lowercased(), "email": email, "description": description, "profileImageUrl": profileImageURL]
        
        Api.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: {
            (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
        })
        
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            onSuccess()
        } catch let logoutError {
            onError(logoutError.localizedDescription)
        }
        
    }
}
