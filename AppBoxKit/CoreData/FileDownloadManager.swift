//
//  FileDownloadManager.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/27/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation

@objcMembers
public class FileDownloadManager: NSObject {
    private var metadataQuery: NSMetadataQuery?
    private var completion: (() -> Void)?
    private var isMonitoring = false

    /// Checks the download status of files in the iCloud container and triggers the completion block once all files are downloaded.
    public func checkAndDownloadFiles(at url: URL, completion: @escaping () -> Void) {
        self.completion = completion
        let fileManager = FileManager.default

        // Start a metadata query to find files in the given URL
        metadataQuery = NSMetadataQuery()
        guard let query = metadataQuery else { return }

        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.predicate = NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, url.path)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMetadataQueryUpdate(_:)),
                                               name: .NSMetadataQueryDidUpdate,
                                               object: query)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMetadataQueryCompletion(_:)),
                                               name: .NSMetadataQueryDidFinishGathering,
                                               object: query)

        query.start()
    }

    @objc private func handleMetadataQueryUpdate(_ notification: Notification) {
        checkDownloadStatus()
    }

    @objc private func handleMetadataQueryCompletion(_ notification: Notification) {
        checkDownloadStatus()
    }

    private func checkDownloadStatus() {
        guard let query = metadataQuery else { return }
        var allFilesDownloaded = true

        query.results.forEach { result in
            guard let item = result as? NSMetadataItem,
                  let fileURL = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
                return
            }

            // Check if it's a directory
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)

            if isDirectory.boolValue {
                // Skip directories
                return
            }

            // Check the download status
            guard let downloadStatus = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String else {
                return
            }

            if downloadStatus != NSMetadataUbiquitousItemDownloadingStatusCurrent {
                allFilesDownloaded = false
                initiateDownload(for: item)
            }
        }

        if allFilesDownloaded {
            metadataQuery?.stop()
            NotificationCenter.default.removeObserver(self)
            metadataQuery = nil

            // Trigger the completion block when all files are downloaded
            completion?()
        }
    }

    private func initiateDownload(for item: NSMetadataItem) {
        guard let fileURL = item.value(forAttribute: NSMetadataItemURLKey) as? URL else { return }
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: fileURL)
        } catch {
            print("Failed to start downloading file at \(fileURL): \(error.localizedDescription)")
        }
    }
}
