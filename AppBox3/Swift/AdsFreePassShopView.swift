//
//  AdsFreePassShopView.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 11/26/23.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI
import StoreKit


struct AdsFreePassShop: View {
    var expirationDate: Date
    var completionHandler: () -> Void
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
    init(expirationDate: Date = Date.distantPast, completionHandler: @escaping () -> Void = {}) {
        self.expirationDate = expirationDate
        self.completionHandler = completionHandler
    }
    
    private var passGroupID = "21416287"
    let privacyUrl = URL(string: "https://www.allaboutapps.net/wordpress/archives/privacy-policy/")!
    let termsOfServiceUrl = URL(string:"https://www.allaboutapps.net/wordpress/archives/terms-of-service/")!
    
    var body: some View {
        if #available(iOS 17, *) {
            ZStack {
                SubscriptionStoreView(groupID: passGroupID, visibleRelationships: .all)
                {
                    VStack {
                        Spacer()

                        Image("iTunesArtwork")
                            .resizable()
                            .frame(width:100, height: 100)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                        Spacer()
                        HStack {
                            Text("Enjoy_faster_app")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                        }
                        if (self.expirationDate != Date.distantPast) {
                            Text("Expires on \(self.expirationDate, formatter: dateFormatter)")
                                .font(.footnote)
                                .padding(.vertical, 4)
                        }
                    }
                    .background {
                        Capsule()
                            .fill(.indigo.opacity(0.5))
                            .blur(radius: 60)
                    }
                }
                .backgroundStyle(.clear)
                .subscriptionStoreButtonLabel(.multiline)
                .subscriptionStorePickerItemBackground(.thinMaterial)
                .subscriptionStoreControlIcon { product, _ in
                    if (product.id == "net.allaboutapps.AppBoxPro.AdsFreePassYearly") {
                        SavesMark()
                    }
                }
                .subscriptionStorePolicyDestination(url: privacyUrl, for:.privacyPolicy)
                .subscriptionStorePolicyDestination(url: termsOfServiceUrl, for:.termsOfService)
                VStack {
                    Spacer()
                    BackgroundBottom()
                }
            }
            .onDisappear {
                completionHandler()
            }
        }
    }
}

struct SavesMark: View {
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 7)
                .fill(.green)
                .frame(width: 55, height: 20)
            Text("Save 50%")
                .font(.system(size: 9, weight:.bold))
        }
    }
}

struct BackgroundBottom: View {
    var body: some View {
        ZStack {
            Text("Your_free_trial")
                .font(.system(size: 10, weight:.ultraLight))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
                .padding(.horizontal, 10)
        }
    }
}

#Preview {
    SavesMark()
}

#Preview {
    AdsFreePassShop()
}

@objcMembers class SubscriptionUtility: NSObject {
    static func subscriptionShopViewController(expirationDate: NSDate, completionHandler: @escaping () -> Void) -> UIViewController {
        return UIHostingController(rootView: AdsFreePassShop(expirationDate: expirationDate as Date, completionHandler: completionHandler))
    }
}
