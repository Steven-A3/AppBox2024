//
//  CredentialProviderViewController.swift
//  Autofill Extension
//
//  Created by BYEONG KWON KWAK on 2023/03/09.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import UIKit
import AuthenticationServices
import CoreData
import OSLog
import LocalAuthentication
import AppBoxKit
import SwiftUI

class CredentialProviderViewController: ASCredentialProviderViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var secureCoverView: UIImageView!
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    @IBOutlet weak var instructionLabel: UILabel!

    var searchController: UISearchController!
    var resultTableController: CredentialResultsTableViewController!
    
    var persistentContainer: NSPersistentContainer!
    var passwords = [Credential]()
    var suggestedPasswords = [Credential]()
    var askedCredentialIdentifiers = [String]()
    
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
    */
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: "AutofillTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: UITableViewController.credentialCellIdentifier)

        if persistentContainer == nil {
            setupCoreDataStack()
        }
        os_log("%@", serviceIdentifiers)

        // viewWillAppear에서 요청받은 아이템이 있는 경우, 해당 항목으로 자동 스크롤을 수행하기 위해서
        // 전달 받은 serviceIdentifiers를 저장해둔다.
        askedCredentialIdentifiers = serviceIdentifiers.map{ $0.identifier }
        
        loadCredentials()
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
        // 사용자 인증 과정이 필요함
        askedCredentialIdentifiers = [credentialIdentity.serviceIdentifier.identifier]
        
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
        
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
     
     위의 함수에서는 에러를 돌려주고 - 여기에서 값을 돌려주자.
     */

    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        // 암호가 설정되어 있는지 확인한다.
//        if let password = A3KeychainUtils.getPassword() {
//            if password.isEmpty { return }
//            
//            let context = LAContext()
//            var error: NSError?
//            
//            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//                let reason = "Access for AppBox Pro"
//                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
//                    if self!.persistentContainer == nil {
//                        self!.setupCoreDataStack()
//                    }
//                    if let passwordCredential = self!.credential(with: credentialIdentity.recordIdentifier!) {
//                        self!.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
//                    }
//                }
//            } else {
//                // Biometric을 사용할 수 없는 경우에는 Passcode/Password를 확인한다.
//                let passcodeCheckViewController = UIViewController.passcodeViewController(with: nil)
//                passcodeCheckViewController?.showLockScreen?(in: self, completion: { success in
//                    
//                })
//                os_log("%@", error!.localizedDescription)
//            }
//        }
    }

    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
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
            requestForCredential.predicate = NSPredicate(format: "walletItemID IN %@ AND (fieldID == %@ OR fieldID == %@)", walletItems, IDofName!, IDofPassword!)
            let credentialResults = try! persistentContainer.viewContext.fetch(requestForCredential)
            let groupedByItemID = Dictionary(grouping: credentialResults, by: {$0!.walletItemID})
            
            for (_, value) in groupedByItemID {
                let name = getValueFromWalletFieldItem(array: value, value: IDofName!)
                let password = getValueFromWalletFieldItem(array: value, value: IDofPassword!)
                os_log("%@, %@", name ?? "nil", password ?? "nil")
                
                if let _ = password {
                    passwords.append(Credential(userName: name!, password: password!, url: identifier))
                }
            }
        }
    }
    
    func loadCredentials() {
        let (IDofName, IDofPassword, IDofURL) = resolveIDs()

        let request = WalletFieldItem.fetchRequest()
        request.predicate = NSPredicate(format: "fieldID == %@ OR fieldID == %@ OR fieldID == %@", IDofName!, IDofPassword!, IDofURL!)
        let result = try! persistentContainer.viewContext.fetch(request)
        //            os_log("%@", result)
        
        let groupedByItemID = Dictionary(grouping: result, by: { $0!.walletItemID } )
        //            os_log("%@", groupByItemID)

        for (_, value) in groupedByItemID {
            guard let name = getValueFromWalletFieldItem(array: value, value: IDofName!) else {
                continue
            }
            guard let password = getValueFromWalletFieldItem(array: value, value: IDofPassword!) else {
                continue
            }
            guard let URL = getValueFromWalletFieldItem(array: value, value: IDofURL!) else {
                continue
            }

            passwords.append(Credential(userName: name, password: password, url: URL))
        }
        passwords.sort(by: {$0.url < $1.url})
        
        for serviceIdentifier in askedCredentialIdentifiers {
            let serviceURL = URL(string: serviceIdentifier)
            guard let host = serviceURL?.host else {
                continue
            }
            let items = host.components(separatedBy: ".")
            let count = items.count
            var domain = host
            if count > 2 {
                let domainItems = items.suffix(2)
                domain = domainItems.joined(separator: ".")
            }
            let filtered = passwords.filter( { $0.url.contains(domain) } )
            if filtered.count > 0 {
                suggestedPasswords.append(contentsOf: filtered)
                passwords.removeAll(where: {$0.url.contains(domain) } )
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar?.topItem?.title = "AppBox Pro"
        
        resultTableController = CredentialResultsTableViewController(style: .insetGrouped)
        resultTableController.autofillExtensionContext = self.extensionContext
        resultTableController.tableView.rowHeight = self.tableView.rowHeight
        resultTableController.navigationItem.searchController = searchController

        searchController = UISearchController(searchResultsController: resultTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.placeholder = "Enter a search term"
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.sizeToFit()

        myNavigationItem.searchController = searchController
        definesPresentationContext = true
        
        myNavigationItem.hidesSearchBarWhenScrolling = false

        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 247/255, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 247/255, alpha: 1.0)
        
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let serviceURL = URL(string: askedCredentialIdentifiers[0] )
        let host = serviceURL?.host
        let items = host?.components(separatedBy: ".")
        let count = items?.count ?? 0
        if count > 2 {
            let domainItems = items!.suffix(2)
            let domain = domainItems.joined(separator: ".")
            
            self.instructionLabel.text = "Choose a password to use for \(domain)."
        } else {
            instructionLabel.text = "Choose a password"
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let context = LAContext()
        var error: NSError?
        
        // Biometric을 사용할 수 있는 경우에만 오토필 기능을 사용 할 수 있다.
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Access for AppBox Pro"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.secureCoverView.isHidden = true
                    }
                }
            }
        }
        
        let serviceURL = URL(string: askedCredentialIdentifiers[0] )
        let host = serviceURL?.host
        let items = host?.components(separatedBy: ".")
        let count = items?.count ?? 0
        if count > 2 {
            let domainItems = items!.suffix(2)
            let domain = domainItems.joined(separator: ".")
            
            if suggestedPasswords.count == 0 {
                if let firstIndex = passwords.firstIndex(where: { $0.url.lowercased().contains( domain ) } ) {
                    tableView.scrollToRow(at: IndexPath(row: firstIndex, section: 1), at: .top, animated: true)
                }
            }
        }
    }
}

extension CredentialProviderViewController: UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let resultViewController = searchController.searchResultsController {
            resultViewController.view.frame = self.tableView.frame
        }
    }
}

extension CredentialProviderViewController: UISearchBarDelegate {
    
}

extension CredentialProviderViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Update the resultsController's filtered items based on the search terms and suggested search token.
        let searchResults = passwords + suggestedPasswords

        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet).lowercased()
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        
        // Filter results down by title, yearIntroduced and introPrice.
        var filtered = searchResults
        var curTerm = searchItems[0]
        var idx = 0
        while curTerm != "" {
            filtered = filtered.filter {
                $0.url.lowercased().contains(curTerm) ||
                $0.userName.lowercased().contains(curTerm)
            }
            idx += 1
            curTerm = (idx < searchItems.count) ? searchItems[idx] : ""
        }
        
        filtered.sort(by: {$0.url.lowercased() < $1.url.lowercased()})
        
        // Apply the filtered results to the search results table.
        if let resultsController = searchController.searchResultsController as? CredentialResultsTableViewController {
            resultsController.filteredCredentials = filtered
            resultsController.tableView.reloadData()
        }
    }

}

extension CredentialProviderViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if suggestedPasswords.count > 0  && section == 0 {
            return "Suggested"
        }
        return "Other"
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if suggestedPasswords.count > 0 && section == 0 {
            return suggestedPasswords.count
        }
        return passwords.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewController.credentialCellIdentifier, for: indexPath) as! CredentialTableViewCell?
        
        let credential = selectItem(indexPath)

        cell?.urlLabel?.text = credential.url
        cell?.usernameLabel?.text = credential.userName
        cell?.iconImageView.image = UIImage(named: credential.iconname())
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cred = selectItem(indexPath)
        
        let passwordCredential = ASPasswordCredential(user: cred.userName, password: cred.password)
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // Get the data for the corresponding row
        let credential = selectItem(indexPath)
        
        // Perform actions, such as navigating to a detail view controller with the item
        let detailView = PasswordDetailView(credential: credential)
        let viewController = UIHostingController(rootView: detailView)
        viewController.modalPresentationStyle = .popover
        present(viewController, animated: true)
    }

    func selectItem(_ indexPath: IndexPath) -> Credential {
        if suggestedPasswords.count > 0 && indexPath.section == 0 {
            return suggestedPasswords[indexPath.row]
        }
        return passwords[indexPath.row]
    }
}

extension StringProtocol {
    var masked: String {
        return String(repeating: "•", count: Swift.max(0, count-3)) + suffix(3)
    }
}
