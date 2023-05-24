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

class PasswordViewContext: ObservableObject {
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var hintText: String = ""
    @Published var themeColor: Color = Color(A3UserDefaults.standard().themeColor())
    @Published var dismissModal: () -> Void = {}
    @Published var parentView: SecuredTextFieldParentProtocol?
    @Published var hideKeyboard: (() -> Void)?

    init(dismissModal: @escaping () -> Void) {
        self.dismissModal = dismissModal
    }
}

class PasswordViewPageContext: ObservableObject {
    @Published var currentPage = 1
    public var pageTitle: String {
        switch self.currentPage {
        case 1:
            return "Enter new password"
        case 2:
            return "Re-enter new password"
        default:
            return "Enter hint text"
        }
    }
    
    init(currentPage: Int = 1) {
        self.currentPage = currentPage
    }
}

struct LoginMainView: View {
    @EnvironmentObject var passwordViewContext: PasswordViewContext
    var dismissModal: () -> Void = {}
    
    var body: some View {
        NavigationStack {
            LoginView()
                .environmentObject(PasswordViewPageContext(currentPage:1))
        }
    }
}

struct LoginView: View, SecuredTextFieldParentProtocol {
    @EnvironmentObject var passwordViewContext: PasswordViewContext
    @EnvironmentObject var passwordViewPageContext: PasswordViewPageContext
    @State var hideKeyboard: (() -> Void)?
        
    // MARK: - Propertiers
    @FocusState private var passwordFieldIsFocused: FocusField?
    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper()
    @State private var nextViewPresented = false

    /// LoginViewPageOne 에 pageNumber를 넘겨주면,  Context의 CurrentPage가 업데이트 됩니다.
    init(passwordFieldIsFocused: FocusField? = nil, keyboardHeightHelper: KeyboardHeightHelper = KeyboardHeightHelper()) {
        self.passwordFieldIsFocused = passwordFieldIsFocused
        self.keyboardHeightHelper = keyboardHeightHelper
    }
    
    let themeColor = Color(A3UserDefaults.standard().themeColor())
    
    // MARK: - View
    var body: some View {
        PasswordBodyView(nextViewPresented: $nextViewPresented)
            .onAppear() {
                passwordViewContext.parentView = self
            }
            .navigationBarBackButtonHidden()
   }
}

struct PasswordBodyView: View {
    @EnvironmentObject var passwordViewContext: PasswordViewContext
    @EnvironmentObject var passwordViewPageContext: PasswordViewPageContext
    @Binding var nextViewPresented: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                NavigationAreaView(nextViewPresented: $nextViewPresented)
                Spacer()
                LockImageView()
                MainTitle(title: passwordViewPageContext.pageTitle)
                Spacer()
                PasswordFieldRow(title: passwordViewPageContext.pageTitle, nextViewPresented: $nextViewPresented)
                Spacer()

            } // VStack
            Spacer()
                .frame(height: geometry.safeAreaInsets.bottom)
        }
        .navigationDestination(isPresented: $nextViewPresented) {
            LoginView()
                .environmentObject(PasswordViewPageContext(currentPage: passwordViewPageContext.currentPage + 1))
        }
    }
}

struct PasswordFieldRow: View {
    @EnvironmentObject var passwordViewContext: PasswordViewContext
    @EnvironmentObject var passwordViewPageContext: PasswordViewPageContext
    @FocusState var passwordFieldIsFocused: FocusField?
    var title: String
    @Binding var nextViewPresented: Bool
    @State private var showCompleteAlert = false
    @State private var showPasswordDoesNotMatchAlert = false
    @State private var showPasswordEmptyAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline) {
                PasswordFieldHelperText(title: passwordHelperTitle)
                Spacer()
                NumberView()
            }
            if passwordViewPageContext.currentPage != 3 {
                SecuredTextFieldView(placeHolderText: passwordViewPageContext.pageTitle,
                                     submitLabel: .next,
                                     onKeyboardSubmit: {
                    if passwordViewPageContext.currentPage == 1 {
                        /// 1 페이지 통과 조건. 암호가 있으면 됨. 없으면 alert
                        if (passwordViewContext.newPassword.count == 0) {
                            showPasswordEmptyAlert = true
                        } else {
                            nextViewPresented = true
                        }
                    } else {
                        if passwordViewContext.newPassword == passwordViewContext.confirmPassword {
                            nextViewPresented = true
                        } else {
                            showPasswordDoesNotMatchAlert = true
                        }
                    }
                },
                                     text: passwordViewPageContext.currentPage == 1 ? $passwordViewContext.newPassword : $passwordViewContext.confirmPassword
                )
                .focused($passwordFieldIsFocused, equals: .password)
                .alert("Password does not match", isPresented: $showPasswordDoesNotMatchAlert) {
                    Button("OK", role: .cancel) {
                        showPasswordDoesNotMatchAlert = false
                    }
                }
                .alert("Please enter new password.", isPresented: $showPasswordEmptyAlert) {
                    Button("OK", role:. cancel) {
                        showPasswordEmptyAlert = false
                    }
                }
            } else {
                TextField(passwordViewPageContext.pageTitle, text:$passwordViewContext.hintText)
                    .frame(height: 50)
                    .padding(.leading, 20)
                    .modifier(TextFieldClearButton(text: $passwordViewContext.hintText))
                    .textContentType(.username)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.gray, lineWidth: 1)
                        )
                    .cornerRadius(30)
                    .focused($passwordFieldIsFocused, equals: .password)
                    .submitLabel(.done)
                    .onSubmit {
                        showCompleteAlert = true
                    }
                    .alert("Password has been set successfully", isPresented: $showCompleteAlert) {
                        Button("OK", role: .cancel) {
                            passwordViewContext.dismissModal()
                        }
                    }
            }
        } // VStack
        .onAppear() {
            passwordFieldIsFocused = .password
        }
        .padding([.leading, .trailing], 27.5)
    }
    
    var passwordHelperTitle: String {
        if passwordViewPageContext.currentPage == 3 {
            return passwordViewContext.hintText.count == 0 ? "" : passwordViewPageContext.pageTitle
        }
        if passwordViewPageContext.currentPage == 1 {
            return passwordViewContext.newPassword.count == 0 ? "" : passwordViewPageContext.pageTitle
        }
        if passwordViewContext.confirmPassword.count == 0 {
            return ""
        }
        if passwordViewContext.newPassword == passwordViewContext.confirmPassword {
            return "Password match"
        }
        return "Password does not match"
    }
}

struct PasswordFieldHelperText: View {
    @EnvironmentObject var passwordViewContext: PasswordViewContext
    var title: String

    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .light, design: .default))
            .padding([.leading], 10)
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
    @EnvironmentObject var passwordViewContext: PasswordViewContext
    @EnvironmentObject var passwordViewPageContext: PasswordViewPageContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var nextViewPresented: Bool
    @State private var presentAlertDone = false

    var body: some View {
        HStack() {
            if passwordViewPageContext.currentPage == 1 {
                NavigationLeftSideView()
            } else {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back")
                        .foregroundColor(passwordViewContext.themeColor)
                }.padding(15)
            }
            Spacer()
            Button {
                switch passwordViewPageContext.currentPage {
                case 1, 2:
                    nextViewPresented = true
                default:
                    presentAlertDone = true
                }
            } label: {
                Text(passwordViewPageContext.currentPage == 3 ? "Done" : "Next")
                    .padding(15)
            }
            .accentColor(passwordViewContext.themeColor)
            .alert("Password has been set successfully.", isPresented: $presentAlertDone) {
                Button("OK", role: .cancel) {
                    passwordViewContext.dismissModal()
                }
            }
            .disabled(nextButtonDisabled)
        }
    }
    
    var nextButtonDisabled: Bool {
        if passwordViewPageContext.currentPage == 1 {
            return passwordViewContext.newPassword.count == 0
        }
        return passwordViewContext.confirmPassword != passwordViewContext.newPassword
    }
}

struct NavigationLeftSideView: View {
    @EnvironmentObject var passwordViewContext: PasswordViewContext

    var body: some View {
        Button(action: {
            passwordViewContext.dismissModal()
        }) {
            Text("Cancel")
                .foregroundColor(passwordViewContext.themeColor)
        }.padding(15)
    }
}

struct LockImageView: View {
    var body: some View {
        Image(uiImage: UIImage(named: "Artua-Mac-Lock.512", in:Bundle(identifier: "net.allaboutapps.AppBoxKit")!, with:nil)!)
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
    @EnvironmentObject var passwordViewContext: PasswordViewContext
    @EnvironmentObject var passwordViewPageContext: PasswordViewPageContext
    
    let bigNumberColor = Color(red: 121/255, green: 121/255, blue: 121/255)
    let smallNumberColor = Color(red: 210/255, green: 210/255, blue: 210/255)
    let bigFont = Font.system(size: 30, weight: .bold, design: .default)
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("1")
                .if(passwordViewPageContext.currentPage != 1) { view in
                    view.foregroundColor(smallNumberColor)
                }
                .if(passwordViewPageContext.currentPage == 1) { view in
                    view.font(bigFont)
                        .foregroundColor(bigNumberColor)
                }
            Text("2")
                .if(passwordViewPageContext.currentPage != 2) { view in
                    view.foregroundColor(smallNumberColor)
                }
                .if(passwordViewPageContext.currentPage == 2) { view in
                    view.font(bigFont)
                        .foregroundColor(bigNumberColor)
                }
            Text("3")
                .if(passwordViewPageContext.currentPage != 3) { view in
                    view.foregroundColor(smallNumberColor)
                }
                .if(passwordViewPageContext.currentPage == 3) { view in
                    view.font(bigFont)
                        .foregroundColor(bigNumberColor)
                }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginMainView()
            .environmentObject(PasswordViewContext(dismissModal: {
                
            }))
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
        return UIHostingController(rootView: LoginMainView(dismissModal: dissmissHandler).environmentObject(PasswordViewContext(dismissModal: dissmissHandler)))
    }
}
