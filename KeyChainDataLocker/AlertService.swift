//
//  AlertService.swift
//  KeyChainDataLocker
//
//  Created by BridgeLabz on 13/07/19.
//  Copyright © 2019 BridgeLabz. All rights reserved.
//

import UIKit

class AlertService {
    
    static func showSimpleAlert(viewController : ViewController?, title : String, message : String) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "Dismiss", style: .default, handler: nil))
        
        viewController?.present(alertVC, animated: true, completion: nil)
    }
    
}
