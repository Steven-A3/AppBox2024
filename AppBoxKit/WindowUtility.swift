//
//  WindowUtility.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 11/29/23.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import UIKit

extension UIWindow {
    @objc static public func getCurrentInterfaceOrientation() -> UIInterfaceOrientation {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return UIInterfaceOrientation.unknown
        }
        
        return windowScene.interfaceOrientation
    }
    
    @objc static public func interfaceOrientationIsPortrait() -> Bool {
        return self.getCurrentInterfaceOrientation().isPortrait
    }
    
    @objc static public func interfaceOrientationIsLandscape() -> Bool {
        return self.getCurrentInterfaceOrientation().isLandscape
    }
}
