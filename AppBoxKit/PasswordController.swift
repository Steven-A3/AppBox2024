//
//  PasswordController.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 2023/04/24.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import UIKit

@objc public class PasswordController: NSObject {
    @objc public func enablePassword(viewController: UIViewController) {
        guard let navigationController = UIStoryboard(name: "Storyboard", bundle: Bundle(identifier: "net.allaboutapps.AppBoxKit")).instantiateViewController(identifier: "passcode_main") as? UINavigationController else {
            fatalError("Unable to instantiate passcode storyboard")
        }
        viewController.present(navigationController, animated: true)
    }
}
