//
//  ViewController.swift
//  KeyChainDataLocker
//
//  Created by BridgeLabz on 11/07/19.
//  Copyright © 2019 BridgeLabz. All rights reserved.
//

import UIKit
import Security

class ViewController: UIViewController {
    @IBOutlet weak var emailInputTextField: UITextField!
    @IBOutlet weak var passwordInputTextField: UITextField!
    @IBOutlet weak var emailShowTextField: UILabel!
    @IBOutlet weak var passwordShowTextField: UILabel!
    
    private let server = "example.com"
    private let accessGroupName = "myKeychainGroup1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func onSavePressed(_ sender: Any) {
        guard let email = emailInputTextField.text else { return }
        guard let password = passwordInputTextField.text else { return }
        
        if isValidText(text : email, fieldTitle: "email") { return }
        if isValidText(text : password, fieldTitle: "password") { return }
        
        
        
        let attributes: [String: Any] = [
            (kSecClass as String): kSecClassInternetPassword,
            (kSecAttrServer as String): server,
            (kSecAttrAccount as String): email,
            (kSecAttrAccessGroup as String) : accessGroupName as AnyObject,
            (kSecAttrSynchronizable as String) : kCFBooleanTrue,
            (kSecValueData as String): password.data(using: .utf8)!]
        
        // checking if any copy of this item exits
        if SecItemCopyMatching(attributes as CFDictionary, nil) == noErr {
            AlertService.showSimpleAlert(viewController: self,
            title: "Item already exists", message: "Update the item instead!")
            return
        }
        
        // Let's add the item to the Keychain! 😄
        let isSuccessful = SecItemAdd(attributes as CFDictionary, nil) == noErr
        
        if isSuccessful {
            AlertService.showSimpleAlert(viewController: self, title: "",
                                         message: "Data saved successfully")
            clearFields()
        } else {
            AlertService.showSimpleAlert(viewController: self, title: "Error",
                                         message: "Something went wrong!")
        }
    }
    
    @IBAction func onUpdatePressed(_ sender: Any) {
        guard let email = emailInputTextField.text else { return }
        guard let password = passwordInputTextField.text else { return }
        
        if isValidText(text : email, fieldTitle: "email") { return }
        if isValidText(text : password, fieldTitle: "password") { return }
        
        let query: [String: Any] = [
            (kSecClass as String): kSecClassInternetPassword,
            (kSecAttrServer as String): server,
            (kSecAttrSynchronizable as String) : kCFBooleanTrue,
            (kSecAttrAccessGroup as String) : accessGroupName as AnyObject,
            (kSecAttrAccount as String): email]
        let attributes: [String: Any] = [kSecValueData as String:
            password.data(using: .utf8)!]
        let statusCode = SecItemUpdate(query as CFDictionary,
                                         attributes as CFDictionary)
        
        if statusCode == noErr {
            AlertService.showSimpleAlert(viewController: self, title: "",
                                         message: "Data updated successfully")
            clearFields()
        } else {
            AlertService.showSimpleAlert(viewController: self, title: "Error",
                                         message: "Status Code : \(statusCode)")
        }
    }
    
    @IBAction func onRetrievePressed(_ sender: Any) {
        let query: [String: Any] = [
            (kSecClass as String): kSecClassInternetPassword,
            (kSecAttrServer as String): server,
            (kSecAttrAccessGroup as String) : accessGroupName as AnyObject,
            (kSecAttrSynchronizable as String) : kCFBooleanTrue,
            (kSecMatchLimit as String): kSecMatchLimitAll,
            (kSecReturnAttributes as String): true,
            (kSecReturnData as String): true]
        var items : CFTypeRef?
        
        // should succeed
        let statusCode = SecItemCopyMatching(query as CFDictionary, &items)
        if statusCode == noErr {
            print("\nItems found!!")
        } else {
            AlertService.showSimpleAlert(viewController: self, title: "",
                                         message: "No items found!")
            print("\nError : \(statusCode)")
        }
        
        emailShowTextField.text = ""
        passwordShowTextField.text = ""
        
        if let items = items as? [[String: Any]] {
            for item in items {
                let email = item[kSecAttrAccount as String] as? String
                let passwordData = item[kSecValueData as String] as? Data
                let password = String(data: passwordData!, encoding: .utf8)
                print("\(email!) - \(password!)")
                
                emailShowTextField.text?.append(email! + ",\n")
                passwordShowTextField.text?.append(password! + ",\n")
            }
        }
    }
    
    @IBAction func onDeleteAllPressed(_ sender: UIButton) {
        var query: [String: Any] = [
            (kSecClass as String): kSecClassInternetPassword,
            (kSecAttrServer as String): server,
            (kSecAttrSynchronizable as String) : kCFBooleanTrue,
            (kSecAttrAccessGroup as String) : accessGroupName as AnyObject,
            (kSecMatchLimit as String): kSecMatchLimitAll,
            (kSecReturnAttributes as String): true,
            (kSecReturnData as String): true]
        var items : CFTypeRef?
        
        let statusCode = SecItemCopyMatching(query as CFDictionary, &items)
        if statusCode == noErr {
            print("\nItems found!")
            
            if let items =  items as? [[String: Any]] {
                query[kSecMatchLimit as String] = nil
                query[kSecReturnAttributes as String] = nil
                query[kSecReturnData as String] = nil
                
                for item in items {
                    let email = item[kSecAttrAccount as String]
                    query[kSecAttrAccount as String] = email
                    let statusCode = SecItemDelete(query as CFDictionary)
                    if statusCode == noErr {
                        print("Item deleted : \(email!)")
                    } else {
                        print(statusCode)
                    }
                }
            }
        } else {
            AlertService.showSimpleAlert(viewController: self, title: "",
                                         message: "No items found!")
            print("\nError : \(statusCode)")
        }
    }
    
    private func isValidText(text : String?, fieldTitle : String) -> Bool {
        if text!.isEmpty {
            AlertService.showSimpleAlert(viewController: self,
            title: "Invalid \(fieldTitle)", message: "\(fieldTitle) can not be empty")
            print("invalid \(fieldTitle)")
            
            return true
        }
        return false
    }
    
    private func clearFields() {
        emailInputTextField.text = nil
        passwordInputTextField.text = nil
    }
}
