//
//  ProgressOverlayView.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 1/14/25.
//  Copyright © 2025 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI

final class ProgressOverlayData: ObservableObject {
    @Published var message: String = ""
}

struct ProgressOverlayView: View {
    @ObservedObject var data: ProgressOverlayData

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 16) {
                GearSpinner()
                
                Text(data.message)
                    .font(.headline)
                    .padding(.top, 8)
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .shadow(radius: 4)
        }
    }
}

struct CircularProgressView: View {
    var progress: Double // Progress value between 0.0 and 1.0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 4)
                .foregroundColor(.brown.opacity(0.1)) // Light black for the background outline
            
            // Progress arc
            Circle()
                .trim(from: 0.0, to: progress) // Defines the visible portion
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90)) // Starts at 12 o'clock
                .animation(.easeInOut(duration: 0.5), value: progress) // Smooth animation
            
            // Inner white circle
            Circle()
                .fill(Color.clear)
                .padding(3)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
}

struct GearSpinner: View {
    @State private var isRotating = false

    var body: some View {
        Image(systemName: "gearshape.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                .linear(duration: 6)
                    .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
    }
}

#Preview {
    // Create a new data model and set the message
    let data = ProgressOverlayData()
    data.message = "Clearing iCloud Data ..."

    // Return the SwiftUI view that you'd see in the real UI.
    return ProgressOverlayView(data: data)
}
