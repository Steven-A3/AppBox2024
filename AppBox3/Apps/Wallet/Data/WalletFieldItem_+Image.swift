//
//  WalletFieldItem_+extension.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/2/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation

@objc(WalletFieldItem_)
extension WalletFieldItem_ {
    // Helper method to fetch the associated WalletField_
    func fetchWalletField() -> WalletField_? {
        // Ensure the fieldID is set
        guard let fieldID = self.fieldID else {
            return nil
        }
        
        // Retrieve the managed object context
        guard let context = self.managedObjectContext else {
            return nil
        }
        
        // Create a fetch request
        let fetchRequest: NSFetchRequest<WalletField_> = WalletField_.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uniqueID == %@", fieldID)
        fetchRequest.fetchLimit = 1 // We only need one match
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first // Return the first (and only) result
        } catch {
            print("Error fetching WalletField: \(error.localizedDescription)")
            return nil
        }
    }
}

extension WalletFieldItem_ {
    /// Returns a boolean indicating whether this wallet field item is an image field.
    @objc public var isImageField: Bool {
        // Fetch the WalletField_ object associated with this WalletFieldItem_
        if let walletField = fetchWalletField() {
            // Check if the type is WalletFieldTypeImage
            return walletField.type == "Image"
        }
        return false
    }
    
    /// Returns the URL for the image associated with this wallet field item.
    /// - Returns: The `NSURL` for the image, or `nil` if the uniqueID is not set.
    @objc public func imageURL() -> NSURL? {
        guard let uniqueID = self.uniqueID else {
            return nil
        }
        
        // Define the relative path for the image file
        let relativePath = "\(iCloudConstants.MEDIA_FILES_PATH)/WalletImages/\(uniqueID)"
        
        // Use application group container URL if iCloud is not available
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER) {
            return appGroupURL.appendingPathComponent(relativePath) as NSURL
        }
        
        // If app group URL is available, return nil
        return nil
    }

    /// Saves an image file to the appropriate destination, either in iCloud or local storage.
    /// - Parameters:
    ///   - sourceURL: The URL of the source image file.
    ///   - error: A pointer to an `NSError` object to report errors.
    /// - Returns: A `Bool` indicating success (`true`) or failure (`false`).
    @objc public func saveImageWithURL(sourceURL: NSURL, error: NSErrorPointer) -> Bool {
        guard let destinationURL = self.imageURL() else {
            setErrorPointer(error, domain: "WalletFieldItem", code: -1, message: "Destination URL could not be determined.")
            return false
        }

        let fileManager = FileManager.default

        // Ensure the destination directory exists
        guard let directoryURL = destinationURL.deletingLastPathComponent else {
            setErrorPointer(error, domain: "WalletFieldItem", code: -2, message: "Failed to determine directory URL.")
            return false
        }

        guard ensureDirectoryExists(at: directoryURL as NSURL, fileManager: fileManager, error: error) else {
            return false
        }

        guard let destinationPath = destinationURL.path else {
            setErrorPointer(error, domain: "WalletFieldItem", code: -3, message: "Failed to retrieve destination path.")
            return false
        }

        do {
            // Check and remove existing file at destination
            if fileManager.fileExists(atPath: destinationPath) {
                try fileManager.removeItem(at: destinationURL as URL)
            }

                // Move the file to local storage
            try fileManager.moveItem(at: sourceURL as URL, to: destinationURL as URL)
            if #available(iOS 17.0, *) {
                let manager = CloudKitMediaFileManagerWrapper.shared
                manager.addFile(url: destinationURL as URL, recordType: A3WalletImageDirectory, customID: self.uniqueID!, ext: nil) { error in
                    if let error = error {
                        print("Failed to add file: \(error.localizedDescription)")
                    } else {
                        print("File added successfully.")
                    }
                }
            }
            return true
        } catch let fileError as NSError {
            setErrorPointer(error, error: fileError)
            return false
        }
    }

    /// Ensures the directory exists at the given URL.
    /// - Parameters:
    ///   - directoryURL: The directory URL to check or create.
    ///   - fileManager: The `FileManager` instance to use.
    ///   - error: A pointer to an `NSError` object to report errors.
    /// - Returns: A `Bool` indicating success (`true`) or failure (`false`).
    func ensureDirectoryExists(at directoryURL: NSURL, fileManager: FileManager, error: NSErrorPointer) -> Bool {
        guard let directoryPath = directoryURL.path else {
            setErrorPointer(error, domain: "WalletFieldItem", code: -2, message: "Invalid directory URL.")
            return false
        }

        if !fileManager.fileExists(atPath: directoryPath) {
            do {
                try fileManager.createDirectory(at: directoryURL as URL, withIntermediateDirectories: true, attributes: nil)
            } catch let creationError as NSError {
                setErrorPointer(error, error: creationError)
                return false
            }
        }
        return true
    }

    /// Sets the error pointer with a specific `NSError`.
    /// - Parameters:
    ///   - errorPointer: The `NSErrorPointer` to update.
    ///   - domain: The error domain.
    ///   - code: The error code.
    ///   - message: A descriptive error message.
    func setErrorPointer(_ errorPointer: NSErrorPointer, domain: String, code: Int, message: String) {
        errorPointer?.pointee = NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }

    /// Sets the error pointer with an existing `NSError`.
    /// - Parameters:
    ///   - errorPointer: The `NSErrorPointer` to update.
    ///   - error: The existing `NSError`.
    func setErrorPointer(_ errorPointer: NSErrorPointer, error: NSError) {
        errorPointer?.pointee = error
    }
}
