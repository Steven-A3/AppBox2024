//
//  PasswordView.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 2023/05/17.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI
import UIKit

enum FocusField: Hashable {
    case none
    case password
}

@available(iOS 15.0, *)
struct LoginView: View, SecuredTextFieldParentProtocol {
    var dismiss: () -> Void = {}

    @State var hideKeyboard: (() -> Void)?
    
    // MARK: - Propertiers
    @State private var password = ""
    @FocusState private var passwordFieldIsFocused: FocusField?
    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper()

    let themeColor = Color(A3UserDefaults.standard().themeColor())
    
    // MARK: - View
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                NavigationView(themeColor: themeColor, dismiss: dismiss)
                Spacer()
                LockImageView()
                MainTitle(title: "Create new passcode")
                Spacer()
                PasswordFieldRow(title: "New passcode", password: $password, passwordFieldIsFocused: _passwordFieldIsFocused, parent: self)
                Spacer()

            } // VStack
            .onAppear() {
                passwordFieldIsFocused = .password
            }
            Spacer()
                .frame(height: geometry.safeAreaInsets.bottom)
        }
    }
}

struct PasswordFieldRow: View {
    var title: String
    @Binding var password: String
    @FocusState var passwordFieldIsFocused: FocusField?
    var parent: SecuredTextFieldParentProtocol
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline) {
                if password.count == 0 {
                    Text(title)
                        .font(.system(size: 15, weight: .light, design: .default))
                        .padding([.leading], 10)
                } else {
                    Text("")
                        .padding([.leading], 10)
                }
                Spacer()
                NumberView(page: 1)
            }
            SecuredTextFieldView(text: $password, parent: parent)
                .focused($passwordFieldIsFocused, equals: .password)
        } // VStack
        .padding([.leading, .trailing], 27.5)
    }
}

struct MainTitle: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.system(size: 25, weight: .light, design: .default))
            .padding([.top, .bottom], 30)
    }
}

struct NavigationView: View {
    @State var themeColor: Color
    var dismiss: () -> Void = {}
    
    var body: some View {
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
    }
}

struct LockImageView: View {
    var body: some View {
        Image(uiImage: UIImage(named: "lock_image", in:Bundle(identifier: "net.allaboutapps.AppBoxKit")!, with:nil)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 250, maxHeight: 250)
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct NumberView: View {
    var page: Int
    let bigNumberColor = Color(red: 121/255, green: 121/255, blue: 121/255)
    let smallNumberColor = Color(red: 210/255, green: 210/255, blue: 210/255)
    let bigFont = Font.system(size: 30, weight: .bold, design: .default)
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("1")
                .if(page != 1) { view in
                    view.foregroundColor(smallNumberColor)
                }
                .if(page == 1) { view in
                    view.font(bigFont)
                        .foregroundColor(bigNumberColor)
                }
            Text("2")
                .if(page != 2) { view in
                    view.foregroundColor(smallNumberColor)
                }
                .if(page == 2) { view in
                    view.font(bigFont)
                        .foregroundColor(bigNumberColor)
                }
            Text("3")
                .if(page != 3) { view in
                    view.foregroundColor(smallNumberColor)
                }
                .if(page == 3) { view in
                    view.font(bigFont)
                        .foregroundColor(bigNumberColor)
                }
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
