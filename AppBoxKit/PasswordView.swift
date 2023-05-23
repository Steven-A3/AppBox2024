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

struct LoginMainPageView: View {
    var dismissModal: () -> Void = {}
    @State private var newPassword = ""
    @State private var hintPhrase = ""
    
    var body: some View {
        NavigationStack {
            LoginViewPageOne(pageNumber: 1, dismissModal: dismissModal, newPassword: $newPassword)
        }
    }
}

struct LoginViewPageOne: View, SecuredTextFieldParentProtocol {
    var pageNumber: Int
    var dismissModal: () -> Void = {}

    @State var hideKeyboard: (() -> Void)?
    
    // MARK: - Propertiers
    @Binding var newPassword: String
    @FocusState private var passwordFieldIsFocused: FocusField?
    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper()

    let themeColor = Color(A3UserDefaults.standard().themeColor())
    
    // MARK: - View
    var body: some View {
        PasswordBodyView(pageNumber:pageNumber, dismissModal: dismissModal, themeColor: themeColor, newPassword: $newPassword, parent: self)
            .navigationBarBackButtonHidden()
    }
}

struct PasswordBodyView: View {
    var pageNumber: Int
    var dismissModal: () -> Void = {}
    var themeColor: Color
    @Binding var newPassword: String
    var parent: SecuredTextFieldParentProtocol

    var body: some View {
        GeometryReader { geometry in
            VStack() {
                NavigationAreaView(themeColor: themeColor, dismissModal: dismissModal, pageNumber: pageNumber, newPassword: $newPassword)
                Spacer()
                LockImageView()
                if pageNumber == 1 {
                    MainTitle(title: "Create new passcode")
                } else {
                    MainTitle(title: "Re-enter new passcode")
                }
                Spacer()
                PasswordFieldRow(title: "New passcode", newPassword: $newPassword, parent: parent, pageNumber: pageNumber)
                Spacer()

            } // VStack
            Spacer()
                .frame(height: geometry.safeAreaInsets.bottom)
        }
    }
}

struct PasswordFieldRow: View {
    var title: String
    @Binding var newPassword: String
    @FocusState var passwordFieldIsFocused: FocusField?
    var parent: SecuredTextFieldParentProtocol
    var pageNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline) {
                if newPassword.count > 0 {
                    PasswordFieldHelperText(title: title, password: $newPassword)
                } else {
                    PasswordFieldHelperText(title: "", password: $newPassword)
                }
                Spacer()
                NumberView(page: pageNumber)
            }
            SecuredTextFieldView(text: $newPassword, parent: parent)
                .focused($passwordFieldIsFocused, equals: .password)
        } // VStack
        .onAppear() {
            passwordFieldIsFocused = .password
        }
        .padding([.leading, .trailing], 27.5)
    }
}

struct PasswordFieldHelperText: View {
    var title: String
    @Binding var password: String
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .light, design: .default))
            .padding([.leading], 10)
            .animation(.easeOut(duration: 0.5), value: password)
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

struct NavigationAreaView: View {
    var themeColor: Color
    var dismissModal: () -> Void = {}
    var pageNumber: Int
    @Binding var newPassword: String
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        HStack() {
            if pageNumber == 1 {
                NavigationLeftSideView(dismissModal: dismissModal, themeColor: themeColor)
            } else {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back")
                        .foregroundColor(themeColor)
                }.padding(15)
            }
            Spacer()
            NavigationLink(destination: {
                LoginViewPageOne(pageNumber: pageNumber + 1, newPassword: $newPassword)
            }, label: {
                Text("Next")
                    .foregroundColor(themeColor)
                    .padding(15)
            })
        }
    }
}

struct NavigationLeftSideView: View {
    var dismissModal: () -> Void = {}
    var themeColor: Color
    
    var body: some View {
        Button(action: {
            dismissModal()
        }) {
            Text("Cancel")
                .foregroundColor(themeColor)
        }.padding(15)
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
        LoginMainPageView()
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
        return UIHostingController(rootView: LoginMainPageView(dismissModal: dissmissHandler))
    }
}
