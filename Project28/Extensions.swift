//
//  AlertController+simpleAlert.swift
//  Project28
//
//  Created by Jake Grant on 2/16/18.
//  Copyright © 2018 Jake Grant. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    convenience init(title: String?, message: String?) {
        self.init(title: title, message: message, preferredStyle: .alert)
        self.addAction(UIAlertAction(title: "OK", style: .default))
    }
}

extension UIViewController {
    
    public func showSimpleAlertControllerOK(alert title: String?, message: String?) {
        let ac = UIAlertController(title: title, message: message)
        self.present(ac, animated: true)
    }
}
