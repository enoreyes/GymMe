//
//  ForgotPasswordViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 8/15/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Loaded")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func forgotPass_TouchUpInside(_ sender: Any) {
        
        AuthService.sendForgotPasswordEmail(email: emailTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Sent Password to Email")
        }, onError: { error in
            
            
            
            ProgressHUD.showError(error)
        })
        
    }

    @IBAction func backButton_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
