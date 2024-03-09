//
//  AskPasswordView.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 2023/05/26.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI
/*
struct AskPasswordMainView: View {
    @EnvironmentObject var askPasswordContext: PasswordViewContext
    @State var showHintText: Bool = false
    @State var showCancelButton: Bool = false

    var body: some View {
        VStack() {
            if showCancelButton {
                NavigationBarRightCancelButton()
            }
            Spacer()
            VStack() {
                LockImageView()
                MainTitle(title: "Enter your password")
                Spacer()
                    .frame(maxHeight: 15)
                SecureFieldRow()
                Spacer()
                    .frame(maxHeight: 10)
                HStack() {
                    Spacer()
                        .frame(width: 15)
                    Button() {
                        showHintText.toggle()
                    } label: {
                        Image(systemName: "lightbulb")
                            .foregroundColor(askPasswordContext.themeColor)
                            .padding(.leading, 0)
                    }
                    Spacer()
                        .frame(width: 20)
                    if (showHintText) {
                        Text(askPasswordContext.hintText)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding([.leading, .trailing,], 30)
            .padding([.top], 15)
        }
    }
}

struct NavigationBarRightCancelButton: View {
    @EnvironmentObject var askPasswordContext: PasswordViewContext
    
    var body: some View {
        HStack() {
            Spacer()
            Button {
                askPasswordContext.completionHandler(false)
            } label: {
                Text("Cancel")
                    .padding(15)
            }
        }.frame(height: 40)
    }
}

struct SecureFieldRow: View {
    @State private var showCompleteAlert = false
    @State private var showPasswordDoesNotMatchAlert = false
    @State private var showPasswordEmptyAlert = false
    @FocusState var passwordFieldIsFocused: FocusField?
    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper()
    @EnvironmentObject var askPasswordContext: PasswordViewContext

    init(passwordFieldIsFocused: FocusField? = nil, keyboardHeightHelper: KeyboardHeightHelper = KeyboardHeightHelper()) {
        self.passwordFieldIsFocused = passwordFieldIsFocused
        self.keyboardHeightHelper = keyboardHeightHelper
    }

    var body: some View {
        VStack() {
            HStack() {
                ZStack() {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke(.gray)
                        .frame(height: 50)
                    SecuredTextFieldView(
                        placeHolderText: "Enter your password",
                        submitLabel: .done,
                        onKeyboardSubmit: {
                            if askPasswordContext.password == A3KeychainUtils.getPassword() {
                                askPasswordContext.completionHandler(true)
                            } else {
                                showPasswordDoesNotMatchAlert = true
                            }
                        },
                        text: $askPasswordContext.password
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

                }
            }
        }
        .onAppear() {
            passwordFieldIsFocused = .password
            askPasswordContext.hintText = A3KeychainUtils.getHint()
        }
    }
}

struct AskPasswordMainView_Previews: PreviewProvider {
    static var previews: some View {
        AskPasswordMainView()
            .environmentObject(PasswordViewContext(completionHandler: { success in
                
            }))
    }
}
*/
