//
//  CoreDataStack+CKRecord.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 12/18/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CloudKit

extension CoreDataStack {
    /// Fetches a record from CloudKit based on record type, field name, and field value.
    /// - Parameters:
    ///   - recordType: The name of the CloudKit record type (e.g., "CD_WalletCategory_").
    ///   - fieldName: The name of the field to filter by (e.g., "CD_uniqueID").
    ///   - fieldValue: The value to search for in the specified field.
    ///   - completion: Completion handler with the fetched `CKRecord` or an error.
    @objc public func fetchCloudKitRecord(
        recordType: NSString,
        fieldName: NSString,
        fieldValue: NSString,
        completion: @escaping (CKRecord?, NSError?) -> Void
    ) {
        // Define the specific CloudKit container
        let container = CKContainer(identifier: "iCloud.net.allaboutapps.AppBox")
        let privateDatabase = container.privateCloudDatabase

        // Create a predicate to filter records
        let predicate = NSPredicate(format: "%K == %@", fieldName as String, fieldValue as String)

        // Create a query for the provided record type
        let query = CKQuery(recordType: recordType as String, predicate: predicate)

        // Perform the query using the latest API for iOS 16+
        Task {
            do {
                // Fetch results using the async/await API
                let (matchResults, _) = try await privateDatabase.records(matching: query, resultsLimit: 1)

                if let firstResult = matchResults.first {
                    let (_, result) = firstResult

                    switch result {
                    case .success(let record):
                        print("Fetched record: \(record)")
                        completion(record, nil)
                    case .failure(let recordError as NSError):
                        print("Error processing record result: \(recordError.localizedDescription)")
                        completion(nil, recordError)
                    }
                } else {
                    print("No matching record found for \(recordType) where \(fieldName) == \(fieldValue).")
                    completion(nil, nil)
                }
            } catch let error as NSError {
                print("Error fetching record: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
}
