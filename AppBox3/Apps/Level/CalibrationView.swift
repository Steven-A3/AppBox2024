//
//  CalibrationView.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 3/11/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI

struct CalibrationView: View {
    @State private var isCalibrate1Enabled = true
    @State private var isCalibrate2Enabled = false
    @State private var resetPressed = false
    @State private var exitPressed = false
    @State private var calibrationDone = false
    
    var calib1Action: () -> Void
    var calib2Action: () -> Void
    var exitAction: () -> Void
    var resetAction: () -> Void
    
    init(calib1Action: @escaping () -> Void, calib2Action: @escaping () -> Void, exitAction: @escaping () -> Void, resetAction: @escaping () -> Void) {
        self.calib1Action = calib1Action
        self.calib2Action = calib2Action
        self.exitAction = exitAction
        self.resetAction = resetAction
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                Image("bg_Inclinometer_surface_cal_iPhoneX")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped() // Clip the image to the bounds of the frame
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        BoldShadowText(NSLocalizedString("CalibrateSurface2Msg", comment: ""), maxWidth: 250)
                            .padding(.trailing, -100)
                        CalibrationButton(title: "Calibrate 2", isEnabled: $isCalibrate2Enabled, action:{
                            calib2Action()
                            calibrationDone = true
                        })
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        BoldShadowText(NSLocalizedString("CalibrateSurface1Msg", comment: ""), maxWidth: 300)
                            .padding(.trailing, -121)
                        CalibrationButton(title:"Calibration 1", isEnabled: $isCalibrate1Enabled, action:{
                            calib1Action()
                            isCalibrate1Enabled = false
                            isCalibrate2Enabled = true
                        })
                        .padding(.trailing, -7)
                    }
                    Spacer()
                }
                SideButtons(
                    exitPressed: $exitPressed,
                    resetPressed: $resetPressed,
                    exitAction: {
                        resetCalibrationState()
                        exitAction()
                    },
                    resetAction: resetAction
                )
                if resetPressed {
                    CustomAlertView(
                        isPresented: $resetPressed,
                        title: "Reset",
                        message: "Do you want to reset the calibration?",
                        yesAction: {
                            print("Yes tapped")
                            // Handle Yes action
                            resetAction()
                            resetPressed = false
                        },
                        noAction: {
                            print("No tapped")
                            // Handle No action
                            resetPressed = false
                        }
                    )
                    .rotationEffect(.degrees(-90)) // Rotate 90 degrees clockwise
                    // Depending on your layout, you might need to adjust the position or size after rotation
                    .animation(.easeInOut, value: resetPressed) // Optional: animate the rotation            }
                }
                if calibrationDone {
                    CustomAlertView(
                        isPresented: $resetPressed,
                        title: "Calibration Done",
                        message: "Do you want to restart the calibration?",
                        yesAction: {
                            print("Yes tapped")
                            // Handle Yes action
                            resetCalibrationState()
                        },
                        noAction: {
                            print("No tapped")
                            // Handle No action
                            resetCalibrationState()
                            exitAction()
                        }
                    )
                    .rotationEffect(.degrees(-90)) // Rotate 90 degrees clockwise
                    // Depending on your layout, you might need to adjust the position or size after rotation
                    .animation(.easeInOut, value: resetPressed) // Optional: animate the rotation            }
                }
            }
        } // GeometryReader
        .edgesIgnoringSafeArea(.all)
    }
    
    private func resetCalibrationState() {
        calibrationDone = false
        isCalibrate1Enabled = true
        isCalibrate2Enabled = false
    }
}

struct BoldShadowText: View {
    var text: String
    var maxWidth: CGFloat
    
    init(_ text: String, maxWidth: CGFloat) {
        self.text = text
        self.maxWidth = maxWidth
    }
    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .bold()
            .shadow(color: .gray, radius: 2, x: 2, y: 2)
            .frame(maxWidth: maxWidth)
            .rotationEffect(.degrees(-90))
    }
}

struct SideButtons: View {
    @Binding var exitPressed: Bool
    @Binding var resetPressed: Bool
    
    let exitAction: () -> Void
    let resetAction: () -> Void
   
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // Exit button action
                    print("Exit button tapped")
                    exitAction()
                }) {
                    Image(systemName: "xmark.circle.fill") // Use a system icon for the exit button
                        .foregroundColor(.white)
                        .font(.title) // Adjust the size as needed
                }
                .padding(.top, 50) // Add some padding to ensure it's not too close to the edge
                .padding(.leading, 20)
                Spacer()
                Button(action: {
                    // Reset button action
                    print("Reset button tapped")
                    resetPressed = true
                }) {
                    Image(systemName: "trash") // Use a system icon for the exit button
                        .foregroundColor(.white)
                        .font(.title) // Adjust the size as needed
                        .rotationEffect(.degrees(-90)) // Rotate the text 90 degrees counter-clockwise
                }
                .padding(.top, 50) // Add some padding to ensure it's not too close to the edge
                .padding(.trailing, 20)
            }
            Spacer()
        }
    }
}

struct CalibrationButton: View {
    var title: String
    @Binding var isEnabled: Bool
    var action: () -> Void
    
    init(title: String, isEnabled: Binding<Bool>, action: @escaping () -> Void) {
        self.title = title
        self._isEnabled = isEnabled
        self.action = action
    }

    private let activeBackground = LinearGradient(gradient: Gradient(colors: [
        Color(red: 1/255, green: 234/255, blue: 0),
        Color(red: 5/255, green: 168/255, blue: 0),
        Color(red: 0/255, green: 106/255, blue: 0)]),
        startPoint: .leading, endPoint: .trailing)
    private let disabledBackground = LinearGradient(gradient: Gradient(colors: [
        Color(red: 1/255, green: 234/255, blue: 0, opacity: 0.5),
        Color(red: 5/255, green: 168/255, blue: 0, opacity: 0.5),
        Color(red: 0/255, green: 106/255, blue: 0, opacity: 0.5)]),
        startPoint: .leading, endPoint: .trailing)

    var body: some View {
        ZStack {
            Button(action: {
                // Action for the button
                print("\(title) button pressed")
                action()
            }) {
                Text(" ")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width:20, height:150)
            }
            .padding() // Add padding around the rotated text
            .background(isEnabled ? activeBackground : disabledBackground) // Set the background color
            .cornerRadius(10) // Rounded corners
            .disabled(!isEnabled)

            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .rotationEffect(.degrees(-90)) // Rotate the text 90 degrees counter-clockwise
                .allowsHitTesting(false)
//                .frame(width:150, height:30)
        } // Set the frame size
        // Adjust the frame if necessary, depending on your layout needs
    }
}

#Preview {
    CalibrationView(calib1Action:{}, calib2Action: {}, exitAction: {}, resetAction: {})
}

#Preview {
    CalibrationButton(title: "Calibration 1", isEnabled: .constant(true), action: {})
}

@objcMembers class CalibrationViewUtility: NSObject {
    static func createCalibrationView(calib1Action: @escaping () -> Void, calib2Action: @escaping () -> Void, exitAction: @escaping () -> Void, resetAction: @escaping () -> Void) -> UIView {
        let calibrationView = CalibrationView(calib1Action: calib1Action, calib2Action: calib2Action, exitAction: exitAction, resetAction: resetAction)
        let hostingController = UIHostingController(rootView: calibrationView)
        return hostingController.view
    }
}

struct CustomAlertView: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let yesAction: () -> Void
    let noAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
            HStack {
                Button("Yes") {
                    isPresented = false
                    yesAction()
                }
                .foregroundColor(.blue)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                Button("No") {
                    isPresented = false
                    noAction()
                }
                .foregroundColor(.red)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .frame(width: 300) // Adjust the frame as necessary to fit the rotated content
        // You might need to adjust this frame size or the layout of the content inside the alert to ensure it looks good when rotated.
    }
}
