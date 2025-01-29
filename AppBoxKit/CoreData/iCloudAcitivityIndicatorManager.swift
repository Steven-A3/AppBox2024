//
//  iCloudAcitivityIndicatorManager.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 1/28/25.
//  Copyright © 2025 ALLABOUTAPPS. All rights reserved.
//

//
//  iCloudAcitivityIndicatorManager.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 1/28/25.
//  Copyright © 2025 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI

struct iCloudActivityView: View {
    @ObservedObject var data: ProgressOverlayData
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text(data.message)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.black.opacity(0.8))
                .textCase(nil)
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.yellow.opacity(0.6))
        )
        .scaleEffect(animate ? 1.0 : 0.97)
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animate)
        .onAppear { animate = true }
        .onDisappear { animate = false }
        .padding()
    }
}

@objcMembers
public class iCloudActivityIndicatorManager: NSObject {
    
    public static let shared = iCloudActivityIndicatorManager()
    
    private let data = ProgressOverlayData()
    
    private var hostingController: UIHostingController<iCloudActivityView>?
    private var hostingView: UIView?
    
    private override init() {
        super.init()
        data.message = ""
        setupiCloudActivityIndicator()
    }
    
    private func setupiCloudActivityIndicator() {
        DispatchQueue.main.async {
            let rootView = iCloudActivityView(data: self.data)
            let controller = UIHostingController(rootView: rootView)
            
            self.hostingController = controller
            self.hostingView = controller.view
            
            // Hide by default
            self.hostingView?.isHidden = true
            
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            controller.view.backgroundColor = .clear
            
            self.layoutViews()
        }
    }
    
    private func layoutViews() {
        guard let controller = hostingController else {
            return
        }
        
        // Find the active window scene
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            
            window.addSubview(controller.view)
            
            // Activate constraints based on device type
            if UIDevice.current.userInterfaceIdiom == .phone {
                // iPhone: Align topAnchor to the window's bottom with an offset
                NSLayoutConstraint.activate([
                    controller.view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    controller.view.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -16)
                ])
            } else {
                // iPad: Align bottomAnchor to the window's bottom
                NSLayoutConstraint.activate([
                    controller.view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    controller.view.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -30)
                ])
            }
        }
    }
    
    /// Show the activity view on the main thread
    public func show(_ message: String) {
        DispatchQueue.main.async {
            // Re-setup if needed
            self.layoutViews()
            self.data.message = message
            self.hostingView?.isHidden = false
            Logger.shared.debug("iCloudActivityIndicatorManager: show, message: \(message)")
        }
    }
    
    /// Hide the activity view on the main thread
    public func hide() {
        DispatchQueue.main.async {
            Logger.shared.debug("iCloudActivityIndicatorManager: hide")
            self.hostingView?.isHidden = true // Important fix
            self.data.message = ""
        }
    }
}
