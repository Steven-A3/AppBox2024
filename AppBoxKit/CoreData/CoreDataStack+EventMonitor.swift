//
//  CoreDataStack+EventMonitor.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 12/20/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

extension CoreDataStack {
    public func startObservingCloudKitEvents() {
        if !isICloudAccountAvailable {
            coreDataReady = true
            return
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloudKitEventNotification(_:)),
            name: NSPersistentCloudKitContainer.eventChangedNotification,
            object: persistentContainer
        )
    }
    
    @objc private func handleCloudKitEventNotification(_ notification: Notification) {
        guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
            print("No event information available in the notification.")
            return
        }
        
        switch event.type {
        case .setup:
            Logger.shared.info("CoreDataStack: Setup event occurred.")
        case .import:
            Logger.shared.info("CoreDataStack: Import event occurred.")
            Logger.shared.info("CoreDataStack: Import event started at \(String(describing: event.startDate))")
            Logger.shared.info("CoreDataStack: Import event ended at \(String(describing: event.endDate))")
            if event.endDate != nil {
                coreDataReady = true
            }
        case .export:
            Logger.shared.info("CoreDataStack: Export event occurred.")
        default :
            Logger.shared.info("CoreDataStack: Unknown event occurred.")
        }
    }
}
