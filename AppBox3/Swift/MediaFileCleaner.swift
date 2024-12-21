//
//  MediaFileCleaner.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/21/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CoreData

@objc
class MediaFileCleaner : NSObject {
    private let fileManager = FileManager.default
    private let localBaseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER)!.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH)
    private let iCloudBaseURL = FileManager.default.url(forUbiquityContainerIdentifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)?.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH)

    private let fileAccessQueue = DispatchQueue(label: "com.yourapp.fileAccessQueue") // Serial queue for file operations

    @objc func cleanUnusedMediaFiles(context: NSManagedObjectContext) {
        let group = DispatchGroup()

        group.enter()
        context.perform {
            self.cleanWalletImages(context: context)
            group.leave()
        }

        group.enter()
        context.perform {
            self.cleanWalletVideos(context: context)
            group.leave()
        }

        group.enter()
        context.perform {
            self.cleanDaysCounterImages(context: context)
            group.leave()
        }

        group.wait() // Ensure all tasks are complete before proceeding
    }

    private func cleanWalletImages(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<WalletFieldItem_> = WalletFieldItem_.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "hasImage == YES")

        do {
            let walletItems = try context.fetch(fetchRequest)
            let validUniqueIDs = Set(walletItems.compactMap { $0.uniqueID })

            deleteFilesNotInRecords(directory: "WalletImages", validIDs: validUniqueIDs, fileNameFormat: { $0 })
        } catch {
            print("Error fetching WalletFieldItem_ with hasImage == YES: \(error)")
        }
    }

    private func cleanWalletVideos(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<WalletFieldItem_> = WalletFieldItem_.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "hasVideo == YES")

        do {
            let walletItems = try context.fetch(fetchRequest)
            let validUniqueIDs = Set(walletItems.compactMap { $0.uniqueID })
            let fileExtensions = walletItems.reduce(into: [String: String]()) { result, item in
                if let id = item.uniqueID, let ext = item.videoExtension {
                    result[id] = ext
                }
            }

            deleteFilesNotInRecords(directory: "WalletVideos", validIDs: validUniqueIDs) { id in
                guard let ext = fileExtensions[id] else { return nil }
                return "\(id)-video.\(ext)"
            }
        } catch {
            print("Error fetching WalletFieldItem_ with hasVideo == YES: \(error)")
        }
    }

    private func cleanDaysCounterImages(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<DaysCounterEvent_> = DaysCounterEvent_.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "photoID != nil")

        do {
            let daysCounterEvents = try context.fetch(fetchRequest)
            let validPhotoIDs = Set(daysCounterEvents.compactMap { $0.photoID })

            deleteFilesNotInRecords(directory: "DaysCounterImages", validIDs: validPhotoIDs, fileNameFormat: { $0 })
        } catch {
            print("Error fetching DaysCounterEvent_ with photoID != nil: \(error)")
        }
    }

    private func deleteFilesNotInRecords(directory: String, validIDs: Set<String>, fileNameFormat: @escaping (String) -> String?) {
        let localDir = localBaseURL.appendingPathComponent(directory)
        let iCloudDir = iCloudBaseURL?.appendingPathComponent(directory)

        // Perform file deletion asynchronously on the queue
        fileAccessQueue.async {
            self.deleteFilesSafely(from: localDir, validIDs: validIDs, fileNameFormat: fileNameFormat)
        }

        if let iCloudDir = iCloudDir {
            fileAccessQueue.async {
                self.deleteFilesSafely(from: iCloudDir, validIDs: validIDs, fileNameFormat: fileNameFormat)
            }
        }
    }

    private func deleteFilesSafely(from directory: URL, validIDs: Set<String>, fileNameFormat: @escaping (String) -> String?) {
        do {
            // List files in the directory
            let fileNames = try fileManager.contentsOfDirectory(atPath: directory.path)
            for fileName in fileNames {
                guard
                    let uniqueID = extractUniqueID(from: fileName),
                    let formattedFileName = fileNameFormat(uniqueID),
                    !validIDs.contains(formattedFileName)
                else { continue }

                // Delete the file
                let filePath = directory.appendingPathComponent(fileName).path
                do {
                    try fileManager.removeItem(atPath: filePath)
                    print("Deleted unused file: \(filePath)")
                } catch {
                    print("Error deleting file at \(filePath): \(error)")
                }
            }
        } catch {
            print("Error listing files in directory \(directory.path): \(error)")
        }
    }
    
    private func extractUniqueID(from fileName: String) -> String? {
        // Extract unique ID from the filename before `-video` or file extension
        if let range = fileName.range(of: "-video") {
            return String(fileName[..<range.lowerBound])
        }
        return fileName.components(separatedBy: ".").first
    }
}
