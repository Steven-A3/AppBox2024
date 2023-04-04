//
//  CredentialProviderViewController.swift
//  Autofill Extension
//
//  Created by BYEONG KWON KWAK on 2023/03/09.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import AuthenticationServices
import CoreData
import OSLog

class CredentialProviderViewController: ASCredentialProviderViewController {

    var persistentContainer: NSPersistentContainer!
    
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
    */
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
    }

    /*
     Implement this method if your extension supports showing credentials in the QuickType bar.
     When the user selects a credential from your app, this method will be called with the
     ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
     Provide the password by completing the extension request with the associated ASPasswordCredential.
     If using the credential would require showing custom UI for authenticating the user, cancel
     the request with error code ASExtensionError.userInteractionRequired.

     */
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        setupCoreDataStack()
        if let passwordCredential = credential(with: credentialIdentity.recordIdentifier!) {
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        } else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
        }
//        let databaseIsUnlocked = true
//        if (databaseIsUnlocked) {
//            let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
//            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
//        } else {
//            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
//        }
    }

    /*
     Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
     ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
     UI and call this method. Show appropriate UI for authenticating the user then provide the password
     by completing the extension request with the associated ASPasswordCredential.

    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
    }
    */

    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }

    @IBAction func passwordSelected(_ sender: AnyObject?) {
        let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }

    func setupCoreDataStack() {
        guard let modelURL = Bundle.main.url(forResource: "AppBox3", withExtension: "momd") else {
            fatalError("Faild to find data model")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }
        persistentContainer = NSPersistentContainer(name: "AppBoxStore", managedObjectModel: model)
        var containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.allaboutapps.appbox")
        // Store location: $(App group container)/Library/AppBox/
        containerURL?.appendPathComponent("Library/AppBox/AppBoxStore.sqlite")
        let description = NSPersistentStoreDescription(url: containerURL!)
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent store\n\(error), \(error.localizedDescription)")
            }
        }
    }
    
    func credential(with recordIdentifier: String) -> ASPasswordCredential? {
        setupCoreDataStack()
        let request = WalletFieldItem.fetchRequest()
        request.predicate = NSPredicate(format: "walletItemID == %@", recordIdentifier)
        let result = try! persistentContainer.viewContext.fetch(request)
        if result.count > 0 {
            let (IDofName, IDofPassword, _) = resolveIDs()
            return ASPasswordCredential(user: getValueFromWalletFieldItem(array: result, value: IDofName!) ?? "",
                                        password: getValueFromWalletFieldItem(array: result, value: IDofPassword!) ?? "")
        }
        return nil
    }
    
    func passwordFor(_ identifier: String) {
        let (IDofName, IDofPassword, IDofURL) = resolveIDs()
        
        let request: NSFetchRequest = WalletFieldItem.fetchRequest()
        request.predicate = NSPredicate(format: "fieldID == %@ AND value CONTAINS %@", IDofURL!, identifier)
        let result = try! persistentContainer.viewContext.fetch(request)
        let walletItems = result.map { $0.walletItemID }
        
        if walletItems.count > 0 {
            let requestForCredential = WalletFieldItem.fetchRequest()
            let predicate = NSPredicate(format: "walletItemID IN %@ AND (fieldID == %@ OR fieldID == %@)", walletItems, IDofName!, IDofPassword!)
            let credentialResults = try! persistentContainer.viewContext.fetch(requestForCredential)
            let groupedByItemID = Dictionary(grouping: credentialResults, by: {$0!.walletItemID})
            
            for (_, value) in groupedByItemID {
                let name = getValueFromWalletFieldItem(array: value, value: IDofName!)
                let password = getValueFromWalletFieldItem(array: value, value: IDofPassword!)
                let URL = getValueFromWalletFieldItem(array: value, value: IDofURL!)
                os_log("%@, %@, %@", name ?? "nil", password ?? "nil", URL ?? "nil")
                
                if let _ = password {
                    
                }
            }
        }
    }

    func resolveIDs() -> (String?, String?, String?) {
        guard let url = Bundle.main.url(forResource: "WalletCategoryPreset", withExtension: "plist") else {
            fatalError("Failed to load preset data")
        }
        let categoryData = try! Data(contentsOf: url)
        let pListData = try! PropertyListSerialization.propertyList(from: categoryData, format: nil)
        guard let categoryArray = pListData as? Array<Dictionary<String, AnyObject>> else {
            return (nil, nil, nil)
        }
        let category = categoryArray.filter {
            $0["name"] as? String == "Accounts"
        }
        if category.count == 0 {
            return (nil, nil, nil)
        }
        
        guard let fields = category[0]["Fields"] as? Array<Dictionary<String, String>> else {
            os_log("%@", category)
            return (nil, nil, nil)
        }
        
        let IDofName = filterByValue(array: fields, key: "name", value: "ID")
        let IDofPassword = filterByValue(array: fields, key: "name", value: "Password")
        let IDofURL = filterByValue(array: fields, key: "name", value: "URL")
        return (IDofName, IDofPassword, IDofURL)
    }
    
    func getValueFromWalletFieldItem(array: [WalletFieldItem], value: String) -> String? {
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
}
