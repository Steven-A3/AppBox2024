//
//  MediaFileManager.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 11/17/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation

@objcMembers
public class MediaFileMover: NSObject {
    private let fileManager = FileManager.default

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
                    do {
                        // Move file
                        try fileManager.moveItem(at: item, to: targetURL)
                        print("Moved file: \(item.lastPathComponent) to \(targetURL.path)")
                    } catch {
                        print("Failed to move file: \(item.lastPathComponent), error: \(error)")
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
