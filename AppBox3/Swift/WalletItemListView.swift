//
//  WalletItemListView.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/31/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI
import CoreData

struct WalletItemListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name)]
    )
    var walletItems: FetchedResults<WalletItem_>

    var body: some View {
        NavigationView {
            List {
                ForEach(walletItems, id: \.objectID) { walletItem in
                    HStack {
                        Text(walletItem.name ?? "Untitled")
                            .font(.body)
                        Spacer()
                        if let updateDate = walletItem.updateDate {
                            Text(updateDate, formatter: dateFormatter)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Wallet Items")
        }
        .onAppear {
            verifyFetchResults()
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    private func verifyFetchResults() {
        guard !walletItems.isEmpty else {
            print("Fetch request returned no results. Verify entity name and attributes.")
            return
        }
    }
}

#Preview {
    WalletItemListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
