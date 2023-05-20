//
//  PasswordViewController.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 2023/04/25.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {
    @IBOutlet weak var newPasswordTextField: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPasswordTextField.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: digit; max-consecutive: 2; minlength: 8;")
        newPasswordTextField.borderColor = A3UserDefaults.standard().themeColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        newPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        self.dismiss(animated: true)
    }
}
