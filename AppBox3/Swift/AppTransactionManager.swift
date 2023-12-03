//
//  AppTransactionManager.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 11/25/23.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import StoreKit

@objcMembers public class AppTransactionManager : NSObject {
    static func isPaidForApp() async -> (Bool, Date) {
        do {
            // Verify app purchase and handle business model change.
            let result: VerificationResult<AppTransaction> = try await AppTransaction.shared
            
            if case .verified(let appTransaction) = result {
                let originalAppVersion = appTransaction.originalAppVersion
                let freeAppVersion = "3.6"
                let purchaseDate = appTransaction.originalPurchaseDate
                return (isPaidAppVersion(originalAppVersion: originalAppVersion,
                                                  freeAppVersion: freeAppVersion), purchaseDate)
            }
        } catch {
            print("Error during verify AppTransaction: \(error)")
        }
        return (false, Date.distantFuture)
    }
    
    static func isPaidAppVersion(originalAppVersion: String, freeAppVersion: String) -> Bool {
        // Convert version strings to arrays of integers for comparison
        let originalVersionNumbers = originalAppVersion.split(separator: ".").compactMap { Int($0) }
        let freeVersionNumbers = freeAppVersion.split(separator: ".").compactMap { Int($0) }

        // Compare each segment of the version numbers
        for (original, free) in zip(originalVersionNumbers, freeVersionNumbers) {
            if original < free {
                // The original app version is less than the free version, so it was paid
                return true
            } else if original > free {
                // The original app version is greater than the free version, so it was not paid
                return false
            }
        }
        
        // If all segments are equal up to the length of the shortest version string,
        // and the original version string is shorter or equal, it means the app was paid for.
        // If the original version string is longer, we assume it was not paid for.
        return originalVersionNumbers.count <= freeVersionNumbers.count
    }
    
    static func checkSubscriptionStatus() async throws -> (Bool, Bool, Date) {
        for await verificationResult in Transaction.currentEntitlements {
            if case .verified(let transaction) = verificationResult {
                // Remove Ads 구매자라면 유료 사용자로 인정
                // 추후 구매일로 부터 1년간 인정할 예정 (?)
                if transaction.productID == "net.allaboutapps.AppBox3.removeAds" {
                    return (true, false, Date.distantFuture)
                }
                // Subscription 구매자라면 만기일자를 확인한다.
                print("Product ID: \(transaction.productID)")
                if let expiryDate = transaction.expirationDate, expiryDate > Date() {
                    return (false, true, expiryDate)
                }
            }
        }
        return (false, false, Date.distantPast)
    }
}

