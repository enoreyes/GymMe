//
//  SignInViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 7/1/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //formatting the email and password text bars
        
        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.tintColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        
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
        
        signInButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
        signInButton.isEnabled = false
        handleTextField()
        
    }
    
    // Dismiss Keyboard if you touch elsewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        
        let hasViewedWalkthrough = defaults.bool(forKey: "hasViewedWalkthrough")
        
        if !hasViewedWalkthrough {
            if let pageVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
                present(pageVC, animated: true, completion: nil)
            }
        }
        
        if Api.User.CURRENT_USER != nil {
            
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
            
        }
    }
    
    func handleTextField() {
        
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            
            //if any above are blank
            signInButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
            signInButton.isEnabled = false
            return
        }
        
        signInButton.setTitleColor(UIColor.red, for: UIControlState.normal)
        signInButton.isEnabled = true
    }
    
    //Sign in using the AuthService.swift class
    
    @IBAction func signInButtonTouchUpInside(_ sender: Any) {
        
        ProgressHUD.show("Waiting...", interaction: false)
        
        view.endEditing(true)
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Successful")
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
        }, onError: { error in
            ProgressHUD.showError(error!)
        })
        
    }
    
}
