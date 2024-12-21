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
    public func backupStoreFile(to backupURL: URL) throws {
        guard let storeURL = self.persistentContainer?.persistentStoreDescriptions.first?.url else {
            throw NSError(domain: "CoreDataBackup", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find the persistent store URL."])
        }
        
        let fileManager = FileManager.default
        
        // Check if the store file exists
        guard fileManager.fileExists(atPath: storeURL.path) else {
            throw NSError(domain: "CoreDataBackup", code: 2, userInfo: [NSLocalizedDescriptionKey: "Persistent store file does not exist."])
        }
        
        // Backup the main SQLite file
        let backupMainFileURL = backupURL
        try fileManager.copyItem(at: storeURL, to: backupMainFileURL)
        print("Main store file backed up to \(backupMainFileURL.path)")
        
        // Backup related files if using SQLite
        let storeDirectory = storeURL.deletingLastPathComponent()
        let fileName = storeURL.lastPathComponent
        
        let walFileURL = storeDirectory.appendingPathComponent("\(fileName)-wal")
        let shmFileURL = storeDirectory.appendingPathComponent("\(fileName)-shm")
        
        let backupWalURL = backupURL.deletingLastPathComponent().appendingPathComponent("\(fileName)-wal")
        let backupShmURL = backupURL.deletingLastPathComponent().appendingPathComponent("\(fileName)-shm")
        
        if fileManager.fileExists(atPath: walFileURL.path) {
            try fileManager.copyItem(at: walFileURL, to: backupWalURL)
            print("WAL file backed up to \(backupWalURL.path)")
        }
        
        if fileManager.fileExists(atPath: shmFileURL.path) {
            try fileManager.copyItem(at: shmFileURL, to: backupShmURL)
            print("SHM file backed up to \(backupShmURL.path)")
        }
    }
}
