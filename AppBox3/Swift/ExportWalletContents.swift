//
//  ExportWalletContents.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/3/23.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import UIKit

@objcMembers public class WalletExtension : NSObject {
    
    // Function to convert HTML string to NSAttributedString
    public func convertHtmlToAttributedString(htmlString: String) -> NSAttributedString? {
        guard let data = htmlString.data(using: .utf8) else { return nil }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
    }
}
