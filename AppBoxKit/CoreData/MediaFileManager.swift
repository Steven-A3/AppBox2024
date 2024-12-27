//
//  MediaFileManager.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 11/17/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

//
//  MediaFileManager.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 11/17/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation

/// A utility class for moving media files from a source directory to an app group container or iCloud.
///
@objcMembers
public class MediaFileMover: NSObject {
    private let fileManager = FileManager.default
    private let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)

    public func moveMediaFiles(from baseURL: URL) throws {
        // Ensure the app group URL is available
        guard let appGroupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER) else {
            throw NSError(domain: "MediaFileMover", code: 1, userInfo: [NSLocalizedDescriptionKey: "App group container URL not available."])
        }

        // Define source directories
        let sourceDirectories = [
            "DaysCounterImages",
            "WalletImages",
            "WalletVideos"
        ].map { baseURL.appendingPathComponent($0) }

        // Define target directories
        let targetBaseURL = appGroupURL.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH)
        let targetDirectories = [
            "DaysCounterImages",
            "WalletImages",
            "WalletVideos"
        ].map { targetBaseURL.appendingPathComponent($0) }

        // Iterate over source and target directories
        for (sourceDir, targetDir) in zip(sourceDirectories, targetDirectories) {
            try moveFilesRecursively(from: sourceDir, to: targetDir)
        }
    }

    public func moveFilesRecursively(from sourceDirectory: URL, to targetDirectory: URL) throws {
        // Ensure the target directory exists
        try createDirectoryIfNotExists(targetDirectory)

        // Skip if the source directory doesn't exist
        guard fileManager.fileExists(atPath: sourceDirectory.path) else {
            print("Source directory does not exist: \(sourceDirectory.path)")
            return
        }

        do {
            // Try to get files and subdirectories in the source directory
            let items = try fileManager.contentsOfDirectory(at: sourceDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for item in items {
                let targetURL = targetDirectory.appendingPathComponent(item.lastPathComponent)
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                    // If item is a directory, move recursively
                    try moveFilesRecursively(from: item, to: targetURL)
                } else {
                    // Move file
                    if ubiquityURL != nil {
                        // Use NSFileCoordinator for coordinated file operations
                        let coordinator = NSFileCoordinator()
                        var coordinatorError: NSError?
                        
                        coordinator.coordinate(writingItemAt: targetURL, options: .forReplacing, error: &coordinatorError) { url in
                            do {
                                // Check if the file already exists at the target URL
                                if fileManager.fileExists(atPath: url.path) {
                                    try fileManager.removeItem(at: url)
                                    print("Removed existing file at \(url.path)")
                                }
                                
                                // Set the file to ubiquitous (move to iCloud)
                                try fileManager.setUbiquitous(true, itemAt: item, destinationURL: url)
                                print("Moved file to iCloud: \(item.lastPathComponent)")
                            } catch {
                                print("Error during coordinated write or setting ubiquitous: \(error)")
                            }
                        }
                        
                        if let error = coordinatorError {
                            print("NSFileCoordinator error: \(error)")
                        }
                    } else {
                        // Move to app group container if iCloud is not available
                        do {
                            if fileManager.fileExists(atPath: targetURL.path) {
                                try fileManager.removeItem(at: targetURL)
                                print("Removed existing file at \(targetURL.path)")
                            }
                            try fileManager.moveItem(at: item, to: targetURL)
                            print("Moved file: \(item.lastPathComponent) to \(targetURL.path)")
                        } catch {
                            print("Error moving file: \(error)")
                        }
                    }
                }
            }

            // Remove the now-empty source directory
            try? fileManager.removeItem(at: sourceDirectory)
        } catch {
            // Catch and handle errors from contentsOfDirectory
            print("Failed to list contents of directory: \(sourceDirectory.path), error: \(error)")
        }
    }
    
    private func createDirectoryIfNotExists(_ url: URL) throws {
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
