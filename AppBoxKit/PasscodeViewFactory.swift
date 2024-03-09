//
//  PasscodeViewFactory.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 2023/06/22.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI

/*
@objc public class PasswordViewFactory: NSObject {
    @objc public static func makePasswordView(showCancelButton: Bool = false, completionHandler: @escaping ( (_ success: Bool) -> Void )) -> UIViewController {
        return UIHostingController(rootView: LoginMainView().environmentObject(PasswordViewContext(completionHandler: completionHandler)))
    }
    
    @objc public static func makeAskPasswordView(showCancelButton: Bool = false, completionHandler: @escaping ( (_ success: Bool) -> Void ) ) -> UIViewController {
        return UIHostingController(rootView: AskPasswordMainView(showCancelButton: showCancelButton).environmentObject(PasswordViewContext(completionHandler: completionHandler)))
    }
    
    @objc public static func makeAskSimplePasscodeView(showCancelButton: Bool = false, completionHandler: @escaping ( ( _ success: Bool) -> Void ) ) -> UIViewController {
        return UIHostingController(rootView: AskSimplePasswordMainView(showCancelButton: showCancelButton).environmentObject(PasswordViewContext(completionHandler: completionHandler)))
    }
    
    @objc public static func makeCreateSimplePasscodeView(completionHandler: @escaping ( ( _ success: Bool) -> Void ) ) -> UIViewController {
        return UIHostingController(rootView: CreateSimplePasscodeMainView().environmentObject(PasswordViewContext(completionHandler: completionHandler)))
    }
    @objc public static func presentPasscodeViewController(showCancelButton: Bool = false, completionHandler: @escaping ( ( _ success: Bool) -> Void ) ) -> Void {
        // Simple Passcode 인지 아닌지에 따라 적절한 ViewController를 만들어서 호출한다.
        let viewController: UIViewController
        if A3UserDefaults.standard().bool(forKey: kUserDefaultsKeyForUseSimplePasscode) {
            viewController = makeAskSimplePasscodeView(showCancelButton:showCancelButton, completionHandler: completionHandler)
        } else {
            viewController = makePasswordView(showCancelButton:showCancelButton, completionHandler: completionHandler)
        }
        let keyWindow = UIApplication().keyWindow
        keyWindow?.addSubview(viewController.view)
        keyWindow?.rootViewController?.addChild(viewController)
    }
    
    @objc public static func showLockScreen(viewController: UIViewController, animation: Bool = true) -> Void {
        let keyWindow = UIApplication().keyWindow
        keyWindow?.addSubview(viewController.view)
        keyWindow?.rootViewController?.addChild(viewController)
    }
}
 */
