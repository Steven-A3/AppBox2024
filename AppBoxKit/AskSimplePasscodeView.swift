//
//  AskSimplePasscodeView.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 2023/05/30.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI

/*
struct AskSimplePasswordMainView: View {
    @EnvironmentObject var askPasswordContext: PasswordViewContext
    @State var countOfFailedAttempt: Int = 0
    @State var showPasswordDoesNotMatchAlert:Bool = false
    @State var showCancelButton: Bool = true
    
    var body: some View {
        VStack() {
            if showCancelButton {
                NavigationBarRightCancelButton()
            }
            Spacer()
            VStack() {
                LockImageView()
                PasscodeField("Enter your passcode") { digits, action in
                    if A3KeychainUtils.getPassword() == digits.concat {
                        askPasswordContext.completionHandler(true)
                    } else {
                        showPasswordDoesNotMatchAlert = true
                        action(false)
                    }
                }
                
                Spacer()
            }
            .alert("Password does not match", isPresented: $showPasswordDoesNotMatchAlert) {
                Button("OK", role: .cancel) {
                    showPasswordDoesNotMatchAlert = false
                }
            }
        }
    }
}

struct AskSimplePasscodeMainView_Previews: PreviewProvider {
    static var previews: some View {
        AskSimplePasswordMainView()
            .environmentObject(PasswordViewContext(completionHandler: { success in
                
            }))
    }
}
*/
