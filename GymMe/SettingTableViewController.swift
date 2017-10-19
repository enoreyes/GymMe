//
//  SettingTableViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 7/16/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

protocol SettingTableViewControllerDelegate {
    func updateUserInfo()
}

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var delegate: SettingTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Edit Profile"
        usernameTextField.delegate = self
        emailTextField.delegate = self
        descriptionTextField.delegate = self
        fetchCurrentUser()
        
    }
    
    func fetchCurrentUser() {
        Api.User.observeCurrentUser { (user) in
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            self.descriptionTextField.text = user.description
            if let profileUrl = URL(string: user.profileImageUrl!) {
                self.profileImageView.sd_setImage(with: profileUrl)
            }
        }
    }
    
    @IBAction func changeProfileButtonTouchUpInside(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveBtnTouchUpInside(_ sender: Any) {
        
        if let profileImg = self.profileImageView.image, let imageData = UIImageJPEGRepresentation(profileImg, 0.5) {            
            ProgressHUD.show("Waiting...")
            AuthService.updateUserInfo(email: emailTextField.text!, username: usernameTextField.text!, description: descriptionTextField.text!, imageData: imageData, onSuccess: {
                ProgressHUD.showSuccess("Success")
                self.delegate?.updateUserInfo()
            }, onError: { (errorMessage) in
                ProgressHUD.showError(errorMessage)
            })
        }
    }
    
    @IBAction func logoutBtnTouchUpInside(_ sender: Any) {
        
        AuthService.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
}

extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // This runs after the user finishes picking the photo for their profile.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profileImageView.image = image
        }
        
        //dismisses the image picker view
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension SettingTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SettingTableViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxCharacter: Int = 140
        return (textView.text?.utf16.count ?? 0) + text.utf16.count - range.length <= maxCharacter
    }

}
