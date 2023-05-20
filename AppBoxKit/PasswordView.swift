//
//  PasswordView.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 2023/05/17.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 15.0, *)
struct LoginView: View, SecuredTextFieldParentProtocol {
    var dismiss: () -> Void = {}
    
    @State var hideKeyboard: (() -> Void)?
    
    // MARK: - Propertiers
    @State private var password = ""
    @FocusState private var passwordFieldIsFocused: Bool
    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper()

    let themeColor = Color(A3UserDefaults.standard().themeColor())
    
    // MARK: - View
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                HStack() {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(themeColor)
                    }.padding(15)
                    Spacer()
                    Button(action: {}) {
                        Text("Next")
                            .foregroundColor(themeColor)
                    }.padding(15)
                }
                Spacer()
                Image(uiImage: UIImage(named: "lock_image", in:Bundle(identifier: "net.allaboutapps.AppBoxKit")!, with:nil)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 250, maxHeight: 250)
                Text("Create new passcode")
                    .font(.system(size: 25, weight: .light, design: .default))
                    .padding([.top, .bottom], 30)
                Spacer()
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .lastTextBaseline) {
                        if password.count == 0 {
                            Text("New Passcode")
                                .font(.system(size: 15, weight: .light, design: .default))
                                .padding([.leading], 10)
                        } else {
                            Text("")
                                .padding([.leading], 10)
                        }
                        Spacer()
                        NumberView()
                    }
                    SecuredTextFieldView(text: $password, parent: self)
                        .focused($passwordFieldIsFocused)
                } // VStack
                .padding([.leading, .trailing], 27.5)
                Spacer()

            } // VStack
            .onAppear() {
                passwordFieldIsFocused = true
            }
            Spacer()
                .frame(height: geometry.safeAreaInsets.bottom)
        }
    }
}

struct NumberView: View {
    let bigNumberColor = Color(red: 121/255, green: 121/255, blue: 121/255)
    let smallNumberColor = Color(red: 210/255, green: 210/255, blue: 210/255)
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("1")
                .font(.system(size: 30, weight: .bold, design: .default))
                .foregroundColor(bigNumberColor)
            Text("2")
                .foregroundColor(smallNumberColor)
            Text("3")
                .foregroundColor(smallNumberColor)
        }
    }
}

extension Color {
    static var themeTextField: Color {
        return Color(red: 220.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, opacity: 1.0)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

class KeyboardHeightHelper: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    init() {
        self.listenForKeyboardNotifications()
    }
    
    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                               object: nil,
                                               queue: .main) { (notification) in
                                                guard let userInfo = notification.userInfo,
                                                    let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                                                
                                                self.keyboardHeight = keyboardRect.height
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification,
                                               object: nil,
                                               queue: .main) { (notification) in
                                                self.keyboardHeight = 0
        }
    }
}

@objc public class PasswordViewFactory: NSObject {
    @objc public static func makePasswordView(dissmissHandler: @escaping ( () -> Void)) -> UIViewController {
        return UIHostingController(rootView: LoginView(dismiss: dissmissHandler))
    }
}
