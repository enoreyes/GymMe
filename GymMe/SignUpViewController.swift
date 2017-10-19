//
//  SignUpViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 7/1/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Formatting Text Fields
        
        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.tintColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        
        usernameTextField.backgroundColor = UIColor.clear
        usernameTextField.tintColor = UIColor.white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        
        //adding the line underneath email
        let emailBottomLayer = CALayer()
        emailBottomLayer.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        emailBottomLayer.backgroundColor = UIColor(white: 1.0, alpha: 0.6).cgColor
        emailTextField.layer.addSublayer(emailBottomLayer)
        
        //adding the line underneath password
        let passwordBottomLayer = CALayer()
        passwordBottomLayer.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        passwordBottomLayer.backgroundColor = UIColor(white: 1.0, alpha: 0.6).cgColor
        passwordTextField.layer.addSublayer(passwordBottomLayer)
        
        //adding the line underneath username
        let usernameBottomLayer = CALayer()
        usernameBottomLayer.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        usernameBottomLayer.backgroundColor = UIColor(white: 1.0, alpha: 0.6).cgColor
        usernameTextField.layer.addSublayer(usernameBottomLayer)
        
        //making profile pic a circle
        profileImage.layer.cornerRadius = 75
        profileImage.clipsToBounds = true
        
        //adds a tap recognizer to profile image view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectProfileImageView))
        
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
        //Input Validation
        
        signUpButton.isEnabled = false
        
        selectedImage = UIImage(named: "profile-placeholder")
        handleTextField()
    }
    
    // Dismiss Keyboard if you touch elsewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    //(IMPLEMENT Check to make sure username is at least 3 letters, password has at least 6)
    
    @objc func textFieldDidChange() {
        guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            
            //if any above are blank
            signUpButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
            signUpButton.isEnabled = false
            return
        }
        
        signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        signUpButton.isEnabled = true
    }
    
    @objc func handleSelectProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func dismissOnClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonTouched(_ sender: Any) {
        
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.5) {
            AuthService.signUp(email: emailTextField.text!, username: usernameTextField.text!, password: passwordTextField.text!, imageData: imageData, onSuccess: {
                
                ProgressHUD.showSuccess("Successful")
                
                AuthService.sendVerificationEmail(onSuccess: {
                    print("Success")
                }, onError: { error in
                    if error != nil {
                        print(error!)
                    }
                })
                
                self.performSegue(withIdentifier: "signUpToTabbarVC", sender: nil)
                
            }, onError: { (errorString) in
                ProgressHUD.showError(errorString)
            })
        } else {
            ProgressHUD.showError("Profile image can't be empty.")
        }
    }
    
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // This runs after the user finishes picking the photo for their profile.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            profileImage.image = image
        }
        
        //dismisses the image picker view
        dismiss(animated: true, completion: nil)
    }
    
    
}
