//
//  CloudKitMediaFileManager.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/29/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CloudKit

/// CloudKitMediaFileManager is a class that manages media files stored in CloudKit.
/// It uses a CloudKit CKSyncEngine to sync files between the local file system and CloudKit.
/// It is iOS 17.0+ only. iCloud syncing is not supported on earlier versions.

@available(iOS 17.0, *)
public actor CloudKitMediaFileManager: CKSyncEngineDelegate {
    /// The CloudKit container to sync with.
    static let container: CKContainer? = CKContainer(identifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)
    static let zoneName = "net.allaboutapps.appbox2025.mediafiles.zone"
    
    /// The sync engine being used to sync.
    /// This is lazily initialized. You can re-initialize the sync engine by setting `_syncEngine` to nil then calling `self.syncEngine`.
    var syncEngine: CKSyncEngine {
        if _syncEngine == nil {
            self.initializeSyncEngine()
        }
        return _syncEngine!
    }
    var _syncEngine: CKSyncEngine?
    
    let syncStateDataURL: URL
    static let defaultSyncStateDataURL: URL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appending(component: "SyncEngineState").appendingPathExtension("json")
    var syncEngineStateSerialization: CKSyncEngine.State.Serialization?
    
    init() {
        syncStateDataURL = Self.defaultSyncStateDataURL
        do {
            let stateDataBlob = try Data(contentsOf: syncStateDataURL)
            syncEngineStateSerialization = try JSONDecoder().decode(CKSyncEngine.State.Serialization.self, from: stateDataBlob)
        } catch {
            Logger.shared.info("Failed to load sync state data: \(error)")
            syncEngineStateSerialization = nil
        }
        Task {
            await self.initializeSyncEngine()
        }
    }
    
    private let appGroupContainerURL: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER)!
    
    func initializeSyncEngine() {
        var configuration = CKSyncEngine.Configuration(
            database: Self.container!.privateCloudDatabase,
            stateSerialization: self.syncEngineStateSerialization,
            delegate: self
        )
        configuration.automaticallySync = true
        let syncEngine = CKSyncEngine(configuration)
        _syncEngine = syncEngine
        Logger.shared.info("Initialized sync engine: \(syncEngine)")
    }
    
    // MARK: - File Management
    private func directory(for recordType: String) -> URL? {
        let subdirectory: String
        switch recordType {
        case "DaysCounterImages":
            subdirectory = "DaysCounterImages"
        case "WalletImages":
            subdirectory = "WalletImages"
        case "WalletVideos":
            subdirectory = "WalletVideos"
        default:
            return nil
        }
        return appGroupContainerURL.appendingPathComponent("Library/AppBox/MediaFiles/\(subdirectory)", isDirectory: true)
    }
    
    private func fileURL(for customID: String, recordType: String, extension ext: String? = nil) -> URL? {
        guard let directory = directory(for: recordType) else { return nil }
        let filename: String
        if recordType == "WalletVideos", let ext = ext {
            filename = "\(customID)-video.\(ext)"
        } else {
            filename = customID
        }
        return directory.appendingPathComponent(filename)
    }
    
    func addFile(_ url: URL, recordType: String, customID: String, extension ext: String? = nil) {
        guard let _ = Self.container else { return }
        saveToCloudKit(recordType: recordType, customID: customID, fileURL: url, extension: ext)
    }
    
    func removeFile(customID: String, recordType: String) {
        deleteFromCloudKit(recordType: recordType, customID: customID)
    }
    
    func image(for customID: String, recordType: String) -> URL? {
        return fileURL(for: customID, recordType: recordType)
    }
    
    func video(for customID: String, recordType: String, extension ext: String) -> URL? {
        return fileURL(for: customID, recordType: recordType, extension: ext)
    }
    
    // MARK: - CloudKit Management
    private func saveToCloudKit(recordType: String, customID: String, fileURL: URL, extension ext: String?) {
        let zoneID = CKRecordZone.ID(zoneName: Self.zoneName)
        let ID = CKRecord.ID(recordName: "\(recordType):\(customID):\(ext ?? "")", zoneID: zoneID)
        
        Logger.shared.info("CloudKitMediaFileManager: add.pendingRecordZoneChanges: \(recordType) \(customID)")
        syncEngine.state.add(pendingRecordZoneChanges: [.saveRecord(ID)])
    }
    
    private func deleteFromCloudKit(recordType: String, customID: String) {
        let zoneID = CKRecordZone.ID(zoneName: Self.zoneName)
        let recordID = CKRecord.ID(recordName: customID, zoneID: zoneID)
        syncEngine.state.add(pendingRecordZoneChanges: [.deleteRecord(recordID)])
    }
    
    // MARK: - CKSyncEngineDelegate
    public func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        Logger.shared.info("CKSync Engine Event: \(event.description)")
        
        switch event {
        case .stateUpdate(let event):
            self.syncEngineStateSerialization = event.stateSerialization
            do {
                let stateDataBlob = try JSONEncoder().encode(self.syncEngineStateSerialization)
                try stateDataBlob.write(to: syncStateDataURL)
            } catch {
                Logger.shared.info("Failed to save sync state data: \(error)")
            }
        case .fetchedRecordZoneChanges(let changes):
            await handleFetchedChanges(changes)
        case .sentRecordZoneChanges(let changes):
            handleSentChanges(changes)
        default:
            break
        }
    }
    
    public func nextRecordZoneChangeBatch(
        _ context: CKSyncEngine.SendChangesContext,
        syncEngine: CKSyncEngine
    ) async -> CKSyncEngine.RecordZoneChangeBatch? {
        let scope = context.options.scope
        let changes = syncEngine.state.pendingRecordZoneChanges.filter {
            scope.contains($0)
        }

        return await CKSyncEngine.RecordZoneChangeBatch(pendingChanges: changes) { recordID in
            // Split recordName to extract recordType, customID, and extension
            let components = recordID.recordName.split(separator: ":").map(String.init)
            guard components.count >= 2 else {
                Logger.shared.error("Invalid recordName format: \(recordID.recordName)")
                return nil
            }

            // Extract recordType, customID, and optional extension
            let recordType = components[0]
            let customID = components[1]
            let ext = components.count > 2 ? components[2] : nil

            // Get file URL
            guard let fileURL = await fileURL(for: customID, recordType: recordType, extension: ext) else {
                Logger.shared.error("Failed to construct fileURL for recordType: \(recordType), customID: \(customID), ext: \(ext ?? "nil")")
                return nil
            }

            // Create CKRecord
            let record = CKRecord(recordType: recordType, recordID: recordID)
            record["customID"] = customID as CKRecordValue
            if let ext = ext {
                record["extension"] = ext as CKRecordValue
            }
            record["asset"] = CKAsset(fileURL: fileURL)

            Logger.shared.info("Providing CKRecord for recordID: \(recordType)\(recordID):\(fileURL.path())")
            return record
        }
    }
    
    private func handleFetchedChanges(_ changes: CKSyncEngine.Event.FetchedRecordZoneChanges) async {
        for modification in changes.modifications {
            let record = modification.record
            let recordType = record.recordType
            // if recordType is DaysCounterImages, WalletImages, WalletVideos then save the file
            if recordType == "DaysCounterImages" || recordType == "WalletImages" || recordType == "WalletVideos" {
                let customID = record["customID"] as? String ?? ""
                let asset = record["asset"] as? CKAsset
                if let fileURL = fileURL(for: customID, recordType: recordType), let assetURL = asset?.fileURL {
                    try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                    try? FileManager.default.copyItem(at: assetURL, to: fileURL)
                    Logger.shared.info( "File saved: \(fileURL)")
                    NotificationCenter.default.post(name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object:nil)
                }
            } else if recordType == "EventRecord" {
                // Handle EventRecord
                let currentDeviceID = await MainActor.run { UIDevice.current.identifierForVendor?.uuidString ?? "" }
                if record["eventType"] == "Reset" && record["ownerDeviceIdentifier"] != currentDeviceID {
                    // Reset the sync engine state
                    CoreDataStack.shared.resetLocalContainer()
                    fatalError("Intenti8onally crashed to reset the app.")
                }
            }
        }
    }
    
    private func handleSentChanges(_ changes: CKSyncEngine.Event.SentRecordZoneChanges) {
        for savedRecord in changes.savedRecords {
            print("Record sent successfully: \(savedRecord.recordID)")
        }
        for failedRecordSave in changes.failedRecordSaves {
            print("Failed to send record: \(failedRecordSave.record.recordID), error: \(failedRecordSave.error)")
        }
    }
}

@available(iOS 17.0, *)
extension CloudKitMediaFileManager {
    /// Adds all files in a directory to CloudKit, using the filenames for customID and extension.
    /// - Parameters:
    ///   - directoryURL: The directory containing the files to add.
    ///   - recordType: The record type to use for each file (e.g., "DaysCounterImages", "WalletImages", "WalletVideos").
    func addFiles(from directoryURL: URL, recordType: String) {
        guard FileManager.default.fileExists(atPath: directoryURL.path, isDirectory: nil) else {
            print("Directory does not exist: \(directoryURL.path)")
            return
        }
        
        let directoryForRecordType = directoryURL.appending(path: recordType)
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryForRecordType, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                let filename = fileURL.deletingPathExtension().lastPathComponent
                let fileExtension = fileURL.pathExtension
                
                // Handle WalletVideos with specific filename format
                if recordType == "WalletVideos" {
                    guard let (uuid, ext) = extractUUIDAndExtension(from: filename, fileExtension: fileExtension) else {
                        print("Skipping file with invalid WalletVideos filename: \(fileURL.lastPathComponent)")
                        continue
                    }
                    addFile(fileURL, recordType: recordType, customID: uuid, extension: ext)
                } else {
                    // Handle other record types
                    guard UUID(uuidString: filename) != nil else {
                        print("Skipping file with invalid UUID filename: \(fileURL.lastPathComponent)")
                        continue
                    }
                    addFile(fileURL, recordType: recordType, customID: filename, extension: fileExtension.isEmpty ? nil : fileExtension)
                }
            }
        } catch {
            print("Failed to read directory contents: \(error.localizedDescription)")
        }
    }
    
    /// Extracts the UUID and extension from a WalletVideos filename.
    /// - Parameters:
    ///   - filename: The filename without its extension (e.g., "{UUID}-video").
    ///   - fileExtension: The file's extension.
    /// - Returns: A tuple containing the UUID and the extension, or `nil` if the filename is invalid.
    private func extractUUIDAndExtension(from filename: String, fileExtension: String) -> (String, String)? {
        let components = filename.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
        guard components.count == 2,
              components[1] == "video",
              let uuid = UUID(uuidString: String(components[0])) else {
            return nil
        }
        return (String(uuid.uuidString), fileExtension)
    }
}

@available(iOS 17.0, *)
extension CloudKitMediaFileManager {
    public func deleteAllRecords(for recordType: String) async {
        func performQuery(cursor: CKQueryOperation.Cursor? = nil) async throws -> ([CKRecord.ID], CKQueryOperation.Cursor?) {
            try await withCheckedThrowingContinuation { continuation in
                let operation: CKQueryOperation
                if let cursor = cursor {
                    operation = CKQueryOperation(cursor: cursor)
                } else {
                    let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
                    let zoneID = CKRecordZone.ID(zoneName: Self.zoneName)
                    operation = CKQueryOperation(query: query)
                    operation.zoneID = zoneID
                }
                
                var recordsToDelete: [CKRecord.ID] = []
                
                operation.recordMatchedBlock = { (_, result) in
                    switch result {
                    case .success(let record):
                        recordsToDelete.append(record.recordID)
                    case .failure(let error):
                        print("Error fetching record: \(error)")
                    }
                }
                
                operation.queryResultBlock = { result in
                    switch result {
                    case .success(let cursor):
                        continuation.resume(returning: (recordsToDelete, cursor))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                
                operation.configuration.isLongLived = true
                Self.container!.privateCloudDatabase.add(operation)
            }
        }
        
        func deleteRecords(recordIDs: [CKRecord.ID], database: CKDatabase) async throws {
            try await withCheckedThrowingContinuation { continuation in
                let modifyOperation = CKModifyRecordsOperation(
                    recordsToSave: nil,
                    recordIDsToDelete: recordIDs
                )
                
                modifyOperation.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                
                modifyOperation.configuration.isLongLived = true
                database.add(modifyOperation)
            }
        }
        
        var cursor: CKQueryOperation.Cursor? = nil
        repeat {
            do {
                let (recordIDs, nextCursor) = try await performQuery(cursor: cursor)
                try await deleteRecords(recordIDs: recordIDs, database: Self.container!.privateCloudDatabase)
                cursor = nextCursor
            } catch {
                print("Error during deletion process: \(error)")
                return
            }
        } while cursor != nil
    }
    
    
    private func fetchRecords(for cursor: CKQueryOperation.Cursor?) async throws -> [CKRecord.ID] {
        try await withCheckedThrowingContinuation { continuation in
            var recordsToDelete: [CKRecord.ID] = []
            
            let operation: CKQueryOperation
            if let cursor = cursor {
                operation = CKQueryOperation(cursor: cursor)
            } else {
                // Handle the case where there is no cursor (this shouldn't happen in the middle of processing).
                continuation.resume(throwing: NSError(domain: "CloudKitMediaFileManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No cursor provided."]))
                return
            }
            
            operation.recordMatchedBlock = { (_, result) in
                switch result {
                case .success(let record):
                    recordsToDelete.append(record.recordID)
                case .failure(let error):
                    print("Error fetching record: \(error)")
                }
            }
            
            operation.queryResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume(returning: recordsToDelete)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            operation.configuration.isLongLived = true
            Self.container!.privateCloudDatabase.add(operation)
        }
    }
    
    /// Ensures a custom record zone exists in the private database. If not, it creates the zone using CKModifyRecordZonesOperation.
    /// - Parameters:
    ///   - completion: A completion handler called with an optional error.
    func ensureMediaFilesRecordZoneExists(completion: @escaping (Error?) -> Void) {
        let container = CKContainer(identifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)
        let privateDatabase = container.privateCloudDatabase
        let zoneID = CKRecordZone.ID(zoneName: Self.zoneName)
        
        let queue = DispatchQueue(label: "com.app.MediaFilesRecordZone", attributes: .concurrent)
        
        queue.async {
            privateDatabase.fetch(withRecordZoneID: zoneID) { fetchedZone, error in
                Task {
                    if let ckError = error as? CKError {
                        switch ckError.code {
                        case .zoneNotFound, .userDeletedZone:
                            // Zone not found or purged; recreate it
                            Logger.shared.debug("Record zone \(Self.zoneName) not found or was purged. Recreating it now.")
                            
                            let newZone = CKRecordZone(zoneID: zoneID)
                            let modifyOperation = CKModifyRecordZonesOperation(
                                recordZonesToSave: [newZone],
                                recordZoneIDsToDelete: nil
                            )
                            
                            modifyOperation.modifyRecordZonesResultBlock = { result in
                                queue.async(flags: .barrier) {
                                    Task {
                                        switch result {
                                        case .success:
                                            Logger.shared.debug("Successfully recreated record zone: \(Self.zoneName)")
                                            completion(nil)
                                        case .failure(let error):
                                            Logger.shared.debug("Failed to recreate record zone: \(error.localizedDescription)")
                                            completion(error)
                                        }
                                    }
                                }
                            }
                            
                            privateDatabase.add(modifyOperation)
                        default:
                            // Handle other CloudKit errors
                            Logger.shared.debug("Error fetching record zone: \(ckError.localizedDescription)")
                            completion(ckError)
                        }
                    } else if let fetchedZone = fetchedZone {
                        // Zone exists
                        Logger.shared.debug("Record zone \(fetchedZone.zoneID.zoneName) already exists.")
                        completion(nil)
                    } else if let otherError = error {
                        // Handle unexpected errors
                        Logger.shared.debug("Error fetching record zone: \(otherError.localizedDescription)")
                        completion(otherError)
                    }
                }
            }
        }
    }
}

@available(iOS 17.0, *)
@objcMembers
public class CloudKitMediaFileManagerWrapper: NSObject {
    public static let shared = CloudKitMediaFileManagerWrapper()
    
    private let manager = CloudKitMediaFileManager()
    
    @objc public func addFile(url: URL, recordType: String, customID: String, ext: String?, completion: @escaping (Error?) -> Void) {
        Task {
            await manager.addFile(url, recordType: recordType, customID: customID, extension: ext)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    @objc public func removeFile(recordType: String, customID: String, completion: @escaping (Error?) -> Void) {
        Task {
            await manager.removeFile(customID: customID, recordType: recordType)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    @objc public func addFiles(from directoryURL: URL, recordType: String, completion: @escaping (Error?) -> Void) {
        Task {
            await manager.addFiles(from: directoryURL, recordType: recordType)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    @objc public func deleteAllRecords(for recordType: String, completion: @escaping (Error?) -> Void) {
        Task {
            await manager.deleteAllRecords(for: recordType)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    @objc public func addAllMediaFiles(from mediaFilesURL: URL, completion: @escaping (Error?) -> Void) {
        Task {
            await manager.ensureMediaFilesRecordZoneExists { error in
                let manager = Self.shared
                
                // Add DaysCounterImages
                manager.addFiles(from: mediaFilesURL, recordType: A3DaysCounterImageDirectory) { error in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    
                    // Add WalletImages
                    manager.addFiles(from: mediaFilesURL, recordType: A3WalletImageDirectory) { error in
                        guard error == nil else {
                            completion(error)
                            return
                        }
                        
                        // Add WalletVideos
                        manager.addFiles(from: mediaFilesURL, recordType: A3WalletVideoDirectory) { error in
                            // Final completion block
                            completion(error)
                        }
                    }
                }
            }
        }
    }
    
    @objc public func ensureMediaFilesRecordZoneExists(completion: @escaping (Error?) -> Void) {
        Task {
            await manager.ensureMediaFilesRecordZoneExists { error in
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
}
