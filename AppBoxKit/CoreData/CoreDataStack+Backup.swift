//
//  CoreDataStack+Backup.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 12/20/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CloudKit

extension CoreDataStack {
    public func backupAllStoreFiles(to backupDirectoryURL: URL) throws {
        let fileManager = FileManager.default
        let storeFilesToBackup = [cloudStoreURL(), localStoreURL()]
        for storeURL in storeFilesToBackup {
            guard let storeURL = storeURL else {
                Logger.shared.debug("Skipping nil store URL.")
                continue
            }
            
            // Ensure the store file exists before proceeding
            guard fileManager.fileExists(atPath: storeURL.path) else {
                Logger.shared.debug("Skipping non-existent store file: \(storeURL.path)")
                continue
            }
            
            let storeFileName = storeURL.lastPathComponent
            let backupStoreFileURL = backupDirectoryURL.appendingPathComponent(storeFileName)
            
            // Backup the main SQLite file
            do {
                try fileManager.copyItem(at: storeURL, to: backupStoreFileURL)
                Logger.shared.info("Backed up store file to: \(backupStoreFileURL.path)")
            }
            catch {
                Logger.shared.error("Failed to backup store file: \(error.localizedDescription)")
                throw error
            }
            
            // Backup associated WAL and SHM files
            let storeDirectory = storeURL.deletingLastPathComponent()
            let walFileURL = storeDirectory.appendingPathComponent("\(storeFileName)-wal")
            let shmFileURL = storeDirectory.appendingPathComponent("\(storeFileName)-shm")
            
            let backupWalURL = backupDirectoryURL.appendingPathComponent("\(storeFileName)-wal")
            let backupShmURL = backupDirectoryURL.appendingPathComponent("\(storeFileName)-shm")
            
            if fileManager.fileExists(atPath: walFileURL.path) {
                try fileManager.copyItem(at: walFileURL, to: backupWalURL)
                Logger.shared.debug("Backed up WAL file to: \(backupWalURL.path)")
            }
            
            if fileManager.fileExists(atPath: shmFileURL.path) {
                try fileManager.copyItem(at: shmFileURL, to: backupShmURL)
                Logger.shared.debug("Backed up SHM file to: \(backupShmURL.path)")
            }
        }
    }
    
    public func getBackupFileList(for storeURL: URL, using fileManager: FileManager) -> [[String: String]] {
        var fileList: [[String: String]] = []
        
        // Ensure the store file exists before proceeding
        guard fileManager.fileExists(atPath: storeURL.path) else {
            print("Skipping non-existent store file: \(storeURL.path)")
            return fileList
        }
        
        let storeFileName = storeURL.lastPathComponent
        
        fileList.append(["name": storeURL.path, "newname": storeFileName])
        
        // Associated WAL and SHM files
        let storeDirectory = storeURL.deletingLastPathComponent()
        let walFileURL = storeDirectory.appendingPathComponent("\(storeFileName)-wal")
        let shmFileURL = storeDirectory.appendingPathComponent("\(storeFileName)-shm")
        
        if fileManager.fileExists(atPath: walFileURL.path) {
            fileList.append(["name": walFileURL.path, "newname": "\(storeFileName)-wal"])
        }
        
        if fileManager.fileExists(atPath: shmFileURL.path) {
            fileList.append(["name": shmFileURL.path, "newname": "\(storeFileName)-shm"])
        }
        
        return fileList
    }
    
    public func purgePersistentHistoryForStore(at storeURL: URL) -> Error? {
        let semaphore = DispatchSemaphore(value: 0) // Create a semaphore
        var resultError: Error? = nil
        
        loadPersistentContainer(modelName: "AppBox2024", baseURL: storeURL) { persistentContainer, description, error in
            if let error = error {
                resultError = error
                semaphore.signal()
                return
            }
            
            guard let persistentContainer = persistentContainer else {
                resultError = NSError(domain: "CoreDataBackup", code: 1, userInfo: [NSLocalizedDescriptionKey: "Persistent container is not available."])
                semaphore.signal()
                return
            }
            
            let context = persistentContainer.newBackgroundContext()
            context.performAndWait {
                let request = NSPersistentHistoryChangeRequest.deleteHistory(before: Date())
                do {
                    try context.execute(request)
                    Logger.shared.info("Persistent history successfully purged.")
                } catch {
                    Logger.shared.error("Failed to purge persistent history: \(error)")
                    resultError = error
                }
                semaphore.signal() // Signal completion
            }
        }
        
        semaphore.wait() // Wait for completion
        return resultError
    }
}
