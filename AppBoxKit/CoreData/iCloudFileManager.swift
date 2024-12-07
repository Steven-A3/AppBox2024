//
//  iCloudFileManager.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 11/17/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//


import Foundation

@objcMembers
public class iCloudConstants: NSObject {
    public static let OLD_ICLOUD_CONTAINER_IDENTIFIER: String = "84XB754BWU.com.e2ndesign.TPremium2"
    public static let ICLOUD_CONTAINER_IDENTIFIER: String = "iCloud.net.allaboutapps.AppBox"
    public static let APP_GROUP_CONTAINER_IDENTIFIER: String = "group.allaboutapps.appbox"
    public static let MEDIA_FILES_PATH: String = "Library/AppBox/MediaFiles"
}

@objcMembers
public class iCloudFileManager: NSObject {
    private let fileManager = FileManager.default
    
    // Check availability of iCloud container
    public func isICloudAvailable() -> Bool {
        return fileManager.ubiquityIdentityToken != nil
    }
    
    // desitnationPath has like this: WalletVideos/filename
    // fileURL must be a fileURL for the source file.
    @objc
    public func uploadMedia(file fileURL: URL, completion: @escaping (NSError?) -> Void) {
        guard let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)?.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH) else {
            let error = NSError(domain: "iCloudFileManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud container not available."])
            completion(error)
            return
        }
        
        guard let extractedPath = extractPathFromFileURL(fileURL) else {
            completion(NSError(domain: "iCloudFileManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid path structure."]))
            return
        }
        
        let destinationURL = iCloudURL.appendingPathComponent(extractedPath)
        DispatchQueue.global(qos: .background).async {
            do {
                try self.fileManager.copyItem(at: fileURL, to: destinationURL)
                completion(nil) // No error
            } catch {
                completion(error as NSError) // Convert Error to NSError
            }
        }
    }
    
    private func extractPathFromFileURL(_ fileURL: URL) -> String? {
        let fullPath = fileURL.path // "/a/b/c/directory/filename"
        let pathComponents = fullPath.split(separator: "/")
        
        guard pathComponents.count >= 2 else {
            print("Invalid path structure")
            return nil
        }
        
        // Extract "directory" and "filename"
        let directory = pathComponents[pathComponents.count - 2] // "directory"
        let filename = pathComponents.last!                      // "filename"
        
        // Combine them to form "directory/filename"
        return "\(directory)/\(filename)"
    }
		
    public func deleteMedia(file fileURL:URL, completion: @escaping (NSError?) -> Void) {
        guard let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)?.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH) else {
            let error = NSError(domain: "iCloudFileManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud container not available."])
            completion(error)
            return
        }
        
        guard let extractedPath = extractPathFromFileURL(fileURL) else {
            let error = NSError(domain: "iCloudFileManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid file URL."])
            completion(error)
            return
        }
        let destinationURL = iCloudURL.appendingPathComponent(extractedPath)
        
        DispatchQueue.global(qos: .background).async {
            do {
                try self.fileManager.removeItem(at: destinationURL)
                completion(nil)
            } catch {
                completion(error as NSError)
            }
        }
    }
    
    // Download all files and directories recursively from iCloud to a local directory
    public func downloadAllFiles(from sourceDir: String, to localDir: URL, progressHandler: ((Double) -> Void)? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)?.appendingPathComponent(sourceDir) else {
            completion(.failure(NSError(domain: "iCloudFileManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud container not available."])))
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let coordinator = NSFileCoordinator()
                var coordinatorError: NSError?
                
                coordinator.coordinate(readingItemAt: iCloudURL, options: [], error: &coordinatorError) { cloudURL in
                    do {
                        try self.recursivelyCopyFiles(from: cloudURL, to: localDir, progressHandler: progressHandler)
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                }
                
                if let error = coordinatorError {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Upload all files and directories recursively from local directories to iCloud
    public func uploadAllFiles(from localDir: URL, to targetDir: String, progressHandler: ((Double) -> Void)? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)?.appendingPathComponent(targetDir) else {
            completion(.failure(NSError(domain: "iCloudFileManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud container not available."])))
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let coordinator = NSFileCoordinator()
                var coordinatorError: NSError?
                
                coordinator.coordinate(writingItemAt: iCloudURL, options: .forReplacing, error: &coordinatorError) { targetURL in
                    do {
                        try self.recursivelyCopyFiles(from: localDir, to: targetURL, progressHandler: progressHandler)
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                }
                
                if let error = coordinatorError {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Remove all files and directories recursively from the iCloud container
    public func removeAllFiles(completion: @escaping (NSError?) -> Void) {
        guard let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER) else {
            let error = NSError(domain: "iCloudFileManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud container not available."])
            completion(error)
            return
        }
        
        let targetURL = iCloudURL.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH)
        DispatchQueue.global(qos: .background).async {
            do {
                let coordinator = NSFileCoordinator()
                var coordinatorError: NSError?
                
                coordinator.coordinate(writingItemAt: targetURL, options: .forDeleting, error: &coordinatorError) { targetURL in
                    do {
                        try self.recursivelyRemoveFiles(at: targetURL)
                        completion(nil)
                    } catch {
                        completion(error as NSError)
                    }
                }
                
                if let error = coordinatorError {
                    completion(error as NSError)
                }
            }
        }
    }
    
    // Helper: Recursively copy files and directories, skipping existing files
    private func recursivelyCopyFiles(from source: URL, to target: URL, progressHandler: ((Double) -> Void)? = nil) throws {
        try createDirectoryIfNotExists(target)
        
        let items = try fileManager.contentsOfDirectory(at: source, includingPropertiesForKeys: nil)
        var progress: Double = 0.0
        let totalItems = Double(items.count)
        
        for item in items {
            let targetItem = target.appendingPathComponent(item.lastPathComponent)
            
            // Skip the file if it already exists in the target directory
            if fileManager.fileExists(atPath: targetItem.path) {
                print("File already exists, skipping: \(targetItem.path)")
                progress += 1.0
                progressHandler?(progress / totalItems)
                continue
            }
            
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: item.path, isDirectory: &isDir), isDir.boolValue {
                // Recursively copy subdirectories
                try recursivelyCopyFiles(from: item, to: targetItem, progressHandler: progressHandler)
            } else {
                // Copy individual files
                try fileManager.copyItem(at: item, to: targetItem)
            }
            
            progress += 1.0
            progressHandler?(progress / totalItems)
        }
    }
    
    // Helper: Recursively remove files and directories
    private func recursivelyRemoveFiles(at url: URL) throws {
        let items = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        
        for item in items {
            if fileManager.fileExists(atPath: item.path, isDirectory: nil) {
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: item.path, isDirectory: &isDir), isDir.boolValue {
                    // Recursively remove subdirectories
                    try recursivelyRemoveFiles(at: item)
                } else {
                    // Remove individual files
                    try fileManager.removeItem(at: item)
                }
            } else {
                // Remove individual files
                try fileManager.removeItem(at: item)
            }
        }
        
        // Remove the directory itself
        try fileManager.removeItem(at: url)
    }
    
    // Helper: Ensure target directory exists
    private func createDirectoryIfNotExists(_ url: URL) throws {
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    // Objective-C compatible wrapper for downloading MediaFiles
    public func downloadMediaFilesToAppGroup(progressHandler: ((NSNumber) -> Void)?, completion: @escaping (NSError?) -> Void) {
        // Ensure iCloud is available
        guard isICloudAvailable() else {
            let error = NSError(domain: "iCloudFileManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud is not available."])
            completion(error)
            return
        }

        // Source directory in iCloud
        let sourceDir = iCloudConstants.MEDIA_FILES_PATH

        // Destination directory in App Group container
        guard let appGroupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER) else {
            let error = NSError(domain: "iCloudFileManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "App Group container URL not available."])
            completion(error)
            return
        }

        let destinationDir = appGroupURL.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH)

        // Perform the download
        downloadAllFiles(
            from: sourceDir,
            to: destinationDir,
            progressHandler: { progress in
                progressHandler?(NSNumber(value: progress)) // Convert progress to NSNumber for Objective-C
            },
            completion: { result in
                switch result {
                case .success():
                    completion(nil) // No error
                case .failure(let error):
                    completion(error as NSError) // Convert Error to NSError
                }
            }
        )
    }

    // Objective-C compatible wrapper for uploading MediaFiles
    public func uploadMediaFilesFromAppGroup(progressHandler: ((NSNumber) -> Void)?, completion: @escaping (NSError?) -> Void) {
        // Ensure iCloud is available
        guard isICloudAvailable() else {
            let error = NSError(domain: "iCloudFileManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud is not available."])
            completion(error)
            return
        }

        // Source directory in App Group container
        guard let appGroupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER) else {
            let error = NSError(domain: "iCloudFileManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "App Group container URL not available."])
            completion(error)
            return
        }

        let sourceDir = appGroupURL.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH)

        // Destination directory in iCloud
        let targetDir = iCloudConstants.MEDIA_FILES_PATH

        // Perform the upload
        uploadAllFiles(
            from: sourceDir,
            to: targetDir,
            progressHandler: { progress in
                progressHandler?(NSNumber(value: progress)) // Convert progress to NSNumber for Objective-C
            },
            completion: { result in
                switch result {
                case .success():
                    completion(nil) // No error
                case .failure(let error):
                    completion(error as NSError) // Convert Error to NSError
                }
            }
        )
    }
}
