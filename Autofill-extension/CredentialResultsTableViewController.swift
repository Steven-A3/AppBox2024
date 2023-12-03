//
//  CredentialResultsTableViewController.swift
//  Autofill-extension
//
//  Created by BYEONG KWON KWAK on 2023/04/08.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import UIKit
import AuthenticationServices
import AppBoxKit

class CredentialResultsTableViewController: UITableViewController {
    var autofillExtensionContext: ASCredentialProviderExtensionContext!
    var filteredCredentials = [Credential]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "AutofillTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: UITableViewController.credentialCellIdentifier)

//        tableView.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 247/255, alpha: 1.0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCredentials.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewController.credentialCellIdentifier, for: indexPath) as! CredentialTableViewCell?
        
        let credential = filteredCredentials[indexPath.row]
        
        cell?.urlLabel?.text = credential.url
        cell?.usernameLabel?.text = credential.userName

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credential = filteredCredentials[indexPath.row]
        
        let passwordCredential = ASPasswordCredential(user: credential.userName, password: credential.password)
        autofillExtensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }
}

extension UITableViewController {
    static let credentialCellIdentifier = "credentialCellID"
    
}
