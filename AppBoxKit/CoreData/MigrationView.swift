//
//  MigrationView.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 10/14/24.
//

import SwiftUI
import DotLottie
import CoreData

struct MigrationView: View {
    var completion: (() -> Void)?
    var oldPersistentContainer: NSPersistentContainer
    var newPersistentContainer: NSPersistentContainer?

    @State private var publisher = NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
    @StateObject private var migrationManager: DataMigrationManager
    @State private var coreDataReady: Bool = false
    
    @State private var monitorCloudKitEventsForMigration = false

    // MARK: - Initializer
    init(completion: (() -> Void)? = nil) {
        self.completion = completion

        let stack = CoreDataStack.shared
        let storeURL = stack.V47StoreURL()
        let oldContainer = stack.loadPersistentContainer(modelName: "AppBox3", storeURL: storeURL)
        self.oldPersistentContainer = oldContainer

        _migrationManager = StateObject(wrappedValue: DataMigrationManager())
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                // Progress View
                ProgressView(titleForCurrentStage(),
                             value: migrationManager.progress,
                             total: 1.0)
                .padding(.horizontal, 30)

                // Animation View
                DotLottieAnimation(fileName: "animation", config: AnimationConfig(autoplay: true, loop: true))
                    .view()
                    .frame(width: 300, height: 300)
                
                Spacer()

                // Dynamic Content
                stageContent()
                    .padding(.horizontal, 30)
                
                Spacer().frame(height: geometry.size.height / 8)
            }
            .onAppear(perform: {
                startOptimization()
            })
            .edgesIgnoringSafeArea(.bottom)
            .onReceive(publisher) { notification in
                if let userInfo = notification.userInfo {
                    if let event = userInfo["event"] as? NSPersistentCloudKitContainer.Event {
                        if event.type == .import && event.endDate != nil {
                            coreDataReady = true
                            if monitorCloudKitEventsForMigration && !migrationManager.isMigrating {
                                monitorCloudKitEventsForMigration = false
                                migrationManager.migrateDataAfterUIChange() {
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func titleForCurrentStage() -> String {
        Logger.shared.debug("coreDataReady: \(coreDataReady), migrationManager.isMigrating: \(migrationManager.isMigrating), migrationManager.isMigrationComplete: \(migrationManager.isMigrationComplete)")
        switch (coreDataReady, migrationManager.isMigrating, migrationManager.isMigrationComplete) {
        case (true, false, false): return "Preparing Optimization"
        case (true, true, false): return "Optimization in Progress"
        case (true, false, true): return "Optimization Complete"
        default: return "Preparing Optimization"
        }
    }

    @ViewBuilder
    private func stageContent() -> some View {
        switch (coreDataReady, monitorCloudKitEventsForMigration, migrationManager.isMigrating, migrationManager.isMigrationComplete) {
        case (true, false, false, true):
            // Completion stage: Start AppBox Pro button
            ActionButton(title: "Start AppBox Pro", action: finishMigration)
        default:
            EmptyView()
        }
    }

    // MARK: - Actions
    private func resetiCloud() {
        CoreDataStack.shared.resetCloudKitSync { success, error in
            let stack = CoreDataStack.shared
            self.monitorCloudKitEventsForMigration = true
            
            if #available(iOS 17.0, *) {
                CloudKitMediaFileManagerWrapper.shared.ensureMediaFilesRecordZoneExists { error in
                    stack.setupStackWithCompletion {
                    }
                }
            } else {
                stack.setupStackWithCompletion {
                }
            }
        }
    }

    private func startOptimization() {
        let stack = CoreDataStack.shared
        self.monitorCloudKitEventsForMigration = true
        if #available(iOS 17.0, *) {
            CloudKitMediaFileManagerWrapper.shared.ensureMediaFilesRecordZoneExists { error in
                stack.setupStackWithCompletion {
                }
            }
        } else {
            stack.setupStackWithCompletion {
            }
        }
    }

    private func finishMigration() {
        completion?()
    }
}

// MARK: - ActionButton Component
struct ActionButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

// MARK: - Preview
#Preview {
    return MigrationView() {
        // Completion action
    }
}
