//
//  EnableSimplePasscodeView.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 2023/06/03.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI
/*
struct CreateSimplePasscodeMainView: View {
    var body: some View {
        NavigationStack {
            EnterNewSimplePasscodeView()
        }
    }
}

struct EnterNewSimplePasscodeView: View {
    @EnvironmentObject var createSimplePasscodeContext: PasswordViewContext
    @State private var navigateToConfirmPasscode = false
    
    var body: some View {
        VStack() {
            HStack() {
                NavigationBarCancelButton()
                Spacer()
            }
            Spacer()
            VStack {
                LockImageView()
                PasscodeField("Enter New Passcode") { digits, action in
                    if digits.concat.count >= 4 {
                        createSimplePasscodeContext.password = digits.concat
                        action(false)
                        navigateToConfirmPasscode = true
                    }
                }
                Spacer()
            }
        }
        .navigationDestination(isPresented: $navigateToConfirmPasscode) {
            ConfirmNewSimplePasscodeView()
        }
    }
}

struct ConfirmNewSimplePasscodeView: View {
    @EnvironmentObject var createSimplePasscodeContext: PasswordViewContext
    @State private var showCompleteAlert = false
    @State private var showMismatchAlert = false
    
    var body: some View {
        ZStack() {
            VStack() {
                Spacer()
                VStack() {
                    LockImageView()
                    PasscodeField("Re-enter New Passcode") { digits, action in
                        if digits.concat != createSimplePasscodeContext.password {
                            action(false)
                            showMismatchAlert = true
                        } else {
                            action(true)
                            A3KeychainUtils.storePassword(createSimplePasscodeContext.password, hint: "")
                            showCompleteAlert = true
                        }
                    }
                    Spacer()
                }
            }
            .alert("Passcode has been set successfully", isPresented: $showCompleteAlert) {
                Button("OK", role: .cancel) {
                    createSimplePasscodeContext.completionHandler(true)
                }
            }
            if showMismatchAlert {
                VStack() {
                    Spacer()
                    HStack() {
                        Text("Passcode does not match.")
                            .font(.callout)
                            .task(resetMismatchState)
                            .foregroundColor(.red)
                    }
                    .padding(.bottom, 10)
                }
            }
        }
    }
    
    @Sendable private func resetMismatchState() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        showMismatchAlert = false
    }
}

struct EnterHintForNewSimplePasscodeView: View {
    @EnvironmentObject var createSimplePasscodeContext: PasswordViewContext
    
    var body: some View {
        VStack() {
            HStack {
                Spacer()
                Button {
                    
                } label: {
                    Text("Done")
                }
            }
            Spacer()
            LockImageView()
            Spacer()
        }
    }
}

struct CreateSimplePasscodeMainView_Previews: PreviewProvider {
    static var previews: some View {
        EnterNewSimplePasscodeView()
            .environmentObject(PasswordViewContext(completionHandler: { success in
                
            }))
    }
}

struct ConfirmSimplePasscode_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmNewSimplePasscodeView()
            .environmentObject(PasswordViewContext(completionHandler: {success in
                
            }))
    }
}

extension UINavigationController {
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
*/
