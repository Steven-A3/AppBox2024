//
//  CredentialDetailView.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 11/24/23.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI

public struct PasswordDetailView: View {
    @State var credential: Credential

    public init(credential: Credential) {
        self._credential = State(initialValue: credential)
    }

    public var body: some View {
        NavigationView {
            Form {
                Section{
                    HStack {
                        Image(credential.iconname())
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text(credential.url).font(.headline)
                    }
                    HStack {
                        Text("User Name")
                        Spacer()
                        Text(credential.userName)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Password")
                        Spacer()
                        SecureField("Password", text: .constant(credential.password))
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("WEBSITE")) {
                    Link(credential.url, destination: URL(string: "https://\(credential.url)")!)
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("Passwords")
            
        }
    }
}

public struct Credential {
    public var userName: String
    public var password: String
    public var url: String
    
    public init(userName: String, password: String, url: String) {
        self.userName = userName
        self.password = password
        self.url = url
    }
    
    public func iconname() -> String {
        let icons = ["wikipedia", "google", "apple", "baidu", "instagram", "twitter", "youtube", "naver", "kakao"]
        for icon in icons {
            if url.lowercased().contains(icon) {
                return icon + "favicon"
            }
        }
        return "defaultfavicon"
    }
}

#Preview {
    PasswordDetailView(credential: Credential(userName:"bk.kwak@gmail.com", password: "password", url: "dropbox.com"))
}
