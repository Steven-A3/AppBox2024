//
//  CredentialIdentityStoreManager.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 2023/03/19.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CoreData
import OSLog
import AuthenticationServices
import AppBoxKit

@objc public class CredentialIdentityStoreManager : NSObject {
    @objc func updateCredentialIdentityStore() {
        let store = ASCredentialIdentityStore.shared
        
        store.getState { state in
            if state.isEnabled {
                self.updateCredentialStore()
            }
        }
    }

    func updateCredentialStore() {
        guard let context = CoreDataStack.shared.persistentContainer?.viewContext else { return }
        
        // Account Catetory를 읽어들인다.
        let url = Bundle.main.url(forResource: "WalletCategoryPreset", withExtension: "plist")!
        let categoryData = try! Data(contentsOf: url)
        let pListData = try! PropertyListSerialization.propertyList(from: categoryData, format: nil)
        guard let categoryArray = pListData as? Array<Dictionary<String, AnyObject>> else {
            return
        }
        // Account Category를 검색
        let category = categoryArray.filter {
            $0["name"] as? String == "Accounts"
        }
        if category.count > 0 {
            // ID of field named "Name" in Account category
            guard let fields = category[0]["Fields"] as? Array<Dictionary<String, String>> else {
                os_log("%@", category)
                return
            }
            let IDofName = filterByValue(array: fields, key: "name", value: "ID")
            let IDofPassword = filterByValue(array: fields, key: "name", value: "Password")
            let IDofURL = filterByValue(array: fields, key: "name", value: "URL")
            
            let request: NSFetchRequest = WalletFieldItem_.fetchRequest()
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "fieldID == %@ OR fieldID == %@ OR fieldID == %@", IDofName!, IDofPassword!, IDofURL!)
            //            request.propertiesToFetch = ["walletItemID", "fieldID", "value"]
            //            request.propertiesToGroupBy = ["walletItemID"]
            //            request.resultType = .dictionaryResultType
            
            let result = try! context.fetch(request)
            //            os_log("%@", result)
            
            let groupByItemID = Dictionary(grouping: result, by: { $0!.walletItemID } )
            //            os_log("%@", groupByItemID)
            
            var passwordCredentialIdentities: [ASPasswordCredentialIdentity] = []
            for (itemID, value) in groupByItemID {
                let name = getValueFromWalletFieldItem(array: value, value: IDofName!)
                let password = getValueFromWalletFieldItem(array: value, value: IDofPassword!)
                let URL = getValueFromWalletFieldItem(array: value, value: IDofURL!)
                os_log("%@, %@, %@", name ?? "nil", password ?? "nil", URL ?? "nil")
                
                if let _ = password {
                    let serviceIdentifier = ASCredentialServiceIdentifier(identifier: URL ?? "any website", type: .URL)
                    passwordCredentialIdentities.append(
                        ASPasswordCredentialIdentity(serviceIdentifier: serviceIdentifier, user: name ?? "userid", recordIdentifier: itemID)
                    )
                }
            }
            os_log("%@", passwordCredentialIdentities)
            
            let store = ASCredentialIdentityStore.shared
            store.getState { state in
                if state.supportsIncrementalUpdates {
                    store.replaceCredentialIdentities(with: passwordCredentialIdentities)
                } else {
                    store.removeAllCredentialIdentities()
                    store.saveCredentialIdentities(passwordCredentialIdentities)
                }
            }
        }
    }
    
    func getValueFromWalletFieldItem(array: [WalletFieldItem_], value: String) -> String? {
        let results = array.filter {
            $0.fieldID == value
        }
        if results.count > 0 {
            return results[0].value
        }
        return nil
    }
    
    func filterByValue(array: Array<Dictionary<String, String>>, key:String, value: String) -> String? {
        let results = array.filter {
            $0[key] == value
        }
        if results.count > 0 {
            return results[0]["uniqueID"]!
        }
        return nil;
    }
    
    @objc func pushPasswordViewController(navigationController: UINavigationController) {
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let homeViewController = mainStoryboard.instantiateViewController(withIdentifier: String(describing: ChangePasswordViewController.self))
        navigationController.pushViewController(homeViewController, animated: true)
    }
}
