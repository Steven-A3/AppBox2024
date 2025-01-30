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
            NotificationCenter.default.post(name: Notification.Name(iCloudConstants.COREDATA_READY_TO_USE_NOTIFICATION), object: nil)
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
        
        let bundle = Bundle(identifier: "net.allaboutapps.AppBoxKit")!
        switch event.type {
        case .setup:
            Logger.shared.info("CoreDataStack: Setup event occurred.")
        case .import:
            Logger.shared.info("CoreDataStack: Import event occurred.")
            if event.endDate == nil {
                iCloudActivityIndicatorManager.shared.show(NSLocalizedString("iCloud importing data...", bundle:bundle, comment: ""))
            } else {
                iCloudActivityIndicatorManager.shared.hide()
            }
            Logger.shared.info("CoreDataStack: Import event started at \(String(describing: event.startDate))")
            Logger.shared.info("CoreDataStack: Import event ended at \(String(describing: event.endDate))")
            if event.endDate != nil {
                coreDataReady = true
                NotificationCenter.default.post(name: Notification.Name(iCloudConstants.COREDATA_READY_TO_USE_NOTIFICATION), object: nil)
            }
        case .export:
            if event.endDate == nil {
                iCloudActivityIndicatorManager.shared.show(NSLocalizedString("iCloud exporting data...", bundle:bundle, comment: ""))
            } else {
                iCloudActivityIndicatorManager.shared.hide()
            }
            Logger.shared.info("CoreDataStack: Export event occurred.")
        default :
            Logger.shared.info("CoreDataStack: Unknown event occurred.")
        }
    }
}
