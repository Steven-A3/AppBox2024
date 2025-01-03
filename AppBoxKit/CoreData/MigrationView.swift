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
            .edgesIgnoringSafeArea(.bottom)
            .onReceive(publisher) { handleNotification($0) }
        }
    }

    // MARK: - Helpers
    private func titleForCurrentStage() -> String {
        switch (coreDataReady, migrationManager.isMigrating, migrationManager.isMigrationComplete) {
        case (true, false, false): return "Preparing Optimization"
        case (true, true, false): return "Optimization in Progress"
        case (true, false, true): return "Optimization Complete"
        default: return "Preparing Optimization"
        }
    }

    @ViewBuilder
    private func stageContent() -> some View {
        switch (coreDataReady, migrationManager.isMigrating, migrationManager.isMigrationComplete) {
        case (false, false, false):
            // Initial stage: No buttons
            HStack {
                ActionButton(title: "Reset iCloud", action: resetiCloud)
                ActionButton(title: "Optimize", action: startOptimization)
            }
        case (true, false, false):
            // Optimization stage: Two buttons
            EmptyView()
        case (true, true, false):
            // Optimization in progress: No buttons
            EmptyView()
        case (true, false, true):
            // Completion stage: Start AppBox Pro button
            ActionButton(title: "Start AppBox Pro", action: finishMigration)
        default:
            EmptyView()
        }
    }

    private func handleNotification(_ notification: Notification) {
        if let event = notification.userInfo?["event"] as? NSPersistentCloudKitContainer.Event,
           event.type == .export {
            coreDataReady = true
            migrationManager.migrateDataAfterUIChange() {}
        }
    }

    // MARK: - Actions
    private func resetiCloud() {
        migrationManager.isMigrating = true
        CoreDataStack.shared.resetCloudKitSync { success, error in
            let stack = CoreDataStack.shared
            stack.setupStackWithCompletion {
                migrationManager.migrateDataAfterUIChange() {}
            }
        }
    }

    private func startOptimization() {
        migrationManager.isMigrating = true
        let stack = CoreDataStack.shared
        stack.setupStackWithCompletion {
            migrationManager.migrateDataAfterUIChange() {}
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
