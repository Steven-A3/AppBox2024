//
//  CustomTextField.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 2023/04/21.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {
    
    var padding: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: 0, left: paddingValue, bottom: 0, right: paddingValue)
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    @IBInspectable var paddingValue: CGFloat = 0
    
    
    @IBInspectable var borderColor: UIColor? = UIColor.clear {
        didSet {
            layer.borderColor = self.borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = self.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = self.cornerRadius
            layer.masksToBounds = self.cornerRadius > 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func commonInit() {
        self.isSecureTextEntry = true;
        self.rightViewMode = .always;
        
        let eyeOnOfButton = UIButton(type: .system)
        eyeOnOfButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        eyeOnOfButton.setImage(imageForEyeButton(), for: .normal)
        eyeOnOfButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        eyeOnOfButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor?.cgColor
    }
    
    func imageForEyeButton() -> UIImage {
        return self.isSecureTextEntry ? UIImage(named: "eye-off-outline")! : UIImage(named: "eye-outline")!
    }
}
