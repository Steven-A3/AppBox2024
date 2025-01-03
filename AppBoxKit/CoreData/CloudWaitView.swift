//
//  CloudWaitView.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 12/21/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI
import DotLottie

struct CloudWaitView: View {
    var completion: (() -> Void)?
    
    @State private var importing = true
    @State private var publisher = NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
    var body: some View {
        VStack {
            DotLottieAnimation(fileName: "animation", config: AnimationConfig(autoplay: true, loop: true))
                .view()
                .frame(width: 300, height: 300)
        }
        .onReceive(publisher) { notification in
            if let userInfo = notification.userInfo {
                if let event = userInfo["event"] as? NSPersistentCloudKitContainer.Event {
                    if event.type == .export {
                        Logger.shared.info("CloudWaitView: Export event occurred.")
                        guard let completion = self.completion else { return }
                        completion()
                    }
                }
            }
        }
    }
}

#Preview {
    CloudWaitView()
}
