//
//  WalletFieldItem_+Video.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/25/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation

extension WalletFieldItem_ {
    /// Returns a `Bool` indicating whether this wallet field item is an image field.
    @objc public var isVideoField: Bool {
        // Fetch the WalletField_ object associated with this WalletFieldItem_
        if let walletField = fetchWalletField() {
            // Check if the type is WalletFieldTypeVideo
            return walletField.type == "Video"
        }
        return false
    }
    
    /// Returns the URL for the video associated with this wallet field item.
    /// - Returns: The `NSURL` for the video, or `nil` if the uniqueID or videoExtension is not set.
    @objc public func videoURL() -> NSURL? {
        guard let uniqueID = self.uniqueID, let videoExtension = self.videoExtension else {
            return nil
        }
        
        let relativePath = "\(iCloudConstants.MEDIA_FILES_PATH)/WalletVideos/\(uniqueID)-video.\(videoExtension)"
        
        // Try to get the App Group container URL if iCloud is not available
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER) {
            return appGroupURL.appendingPathComponent(relativePath) as NSURL
        }
        
        // Fallback to nil if the App Group container URL is not available
        return nil
    }

    /// Saves a video file to the appropriate destination, either in iCloud or local storage.
    /// - Parameters:
    ///   - sourceURL: The URL of the source video file.
    ///   - error: A pointer to an `NSError` object to report errors.
    /// - Returns: A `Bool` indicating success (`true`) or failure (`false`).
    @objc public func saveVideoAtURL(sourceURL: NSURL, error: NSErrorPointer) -> Bool {
        // Get the destination URL using the videoURL function
        guard let destinationURL = self.videoURL() else {
            setErrorPointer(error, domain: "WalletFieldItem", code: -1, message: "Failed to determine destination URL for video.")
            return false
        }

        let fileManager = FileManager.default

        // Ensure the destination directory exists
        guard let directoryURL = destinationURL.deletingLastPathComponent else {
            setErrorPointer(error, domain: "WalletFieldItem", code: -2, message: "Failed to determine directory for video.")
            return false
        }

        guard ensureDirectoryExists(at: directoryURL as NSURL, fileManager: fileManager, error: error) else {
            return false
        }

        guard let destinationPath = destinationURL.path else {
            setErrorPointer(error, domain: "WalletFieldItem", code: -3, message: "Failed to retrieve destination path for video.")
            return false
        }

        do {
            // Check and remove existing file at the destination
            if fileManager.fileExists(atPath: destinationPath) {
                try fileManager.removeItem(at: destinationURL as URL)
            }

            // Move the video file to local storage
            try fileManager.moveItem(at: sourceURL as URL, to: destinationURL as URL)
            return true
        } catch let fileError as NSError {
            setErrorPointer(error, error: fileError)
            return false
        }
    }
}
