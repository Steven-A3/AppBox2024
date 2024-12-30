//
//  MediaFileManager.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 11/17/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation

/// A utility class for moving media files from a source directory to an app group container or iCloud.
@objcMembers
public class MediaFileMover: NSObject {
    private let fileManager = FileManager.default

    /// Moves media files from the specified source directory to the appropriate target directory.
    /// - Parameter baseURL: The base URL of the source directory.
    /// - Throws: An error if the operation fails.
    public func moveMediaFiles(from baseURL: URL) throws {
        guard let appGroupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER) else {
            throw NSError(domain: "MediaFileMover", code: 1, userInfo: [NSLocalizedDescriptionKey: "App group container URL not available."])
        }

        // Determine the target base URL (iCloud or app group container)
        let targetBaseURL = appGroupURL.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH)

        // Define source and target directories
        let directoryNames = ["DaysCounterImages", "WalletImages", "WalletVideos"]
        let sourceDirectories = directoryNames.map { baseURL.appendingPathComponent($0) }
        let targetDirectories = directoryNames.map { targetBaseURL.appendingPathComponent($0) }

        // Move files for each pair of directories
        try zip(sourceDirectories, targetDirectories).forEach { source, target in
            try moveFilesRecursively(from: source, to: target)
        }
    }

    /// Recursively moves files from a source directory to a target directory.
    /// - Parameters:
    ///   - sourceDirectory: The source directory URL.
    ///   - targetDirectory: The target directory URL.
    /// - Throws: An error if the operation fails.
    @objc public func moveFilesRecursively(from sourceDirectory: URL, to targetDirectory: URL) throws {
        try createDirectoryIfNotExists(at: targetDirectory)

        guard fileManager.fileExists(atPath: sourceDirectory.path) else {
            print("Source directory does not exist: \(sourceDirectory.path)")
            return
        }

        do {
            let items = try fileManager.contentsOfDirectory(at: sourceDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            for item in items {
                let targetURL = targetDirectory.appendingPathComponent(item.lastPathComponent)
                var isDirectory: ObjCBool = false

                if fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory), isDirectory.boolValue {
                    // Recursively handle directories
                    try moveFilesRecursively(from: item, to: targetURL)
                } else {
                    // Move individual file
                    try moveFile(item, to: targetURL)
                }
            }

            // Remove the empty source directory
            try? fileManager.removeItem(at: sourceDirectory)
        } catch {
            print("Failed to process directory: \(sourceDirectory.path), error: \(error)")
        }
    }

    /// Moves a single file to the target location.
    /// - Parameters:
    ///   - sourceFile: The source file URL.
    ///   - targetURL: The target file URL.
    /// - Throws: An error if the operation fails.
    private func moveFile(_ sourceFile: URL, to targetURL: URL) throws {
        if fileManager.fileExists(atPath: targetURL.path) {
            try fileManager.removeItem(at: targetURL)
            print("Removed existing file at \(targetURL.path)")
        }
        try fileManager.moveItem(at: sourceFile, to: targetURL)
        print("Moved file: \(sourceFile.lastPathComponent) to \(targetURL.path)")
    }

    /// Ensures that a directory exists at the given URL.
    /// - Parameter url: The directory URL.
    /// - Throws: An error if the directory cannot be created.
    private func createDirectoryIfNotExists(at url: URL) throws {
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
