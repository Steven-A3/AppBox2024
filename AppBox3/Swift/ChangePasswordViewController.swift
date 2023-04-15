//
//  ChangePasswordViewController.swift
//  AutoPassword-iOS12
//
//  Created by Vineet Choudhary on 23/09/18.
//  Copyright © 2018 Developer Insider. All rights reserved.
//

import UIKit

@objc class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var usernameTextField: ATextField!
    @IBOutlet weak var newPasswordTextField: ATextField!
    @IBOutlet weak var confirmNewPasswordTextField: ATextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //username can be readonly here
        usernameTextField.isEnabled = false
        usernameTextField.textContentType = .username
        usernameTextField.keyboardType = .emailAddress
        usernameTextField.text = "Username"
        
        newPasswordTextField.textContentType = .newPassword
        confirmNewPasswordTextField.textContentType = .newPassword
    }
    
    @IBAction func changePasswordAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    

}

class ATextField : UITextField {
    
}
