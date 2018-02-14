//
//  ViewController.swift
//  Project28
//
//  Created by Jake Grant on 2/13/18.
//  Copyright © 2018 Jake Grant. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        // keyboard frame adjusting
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        // app gets backgrounded or multitasked
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        title = "Nothing to see here"
    }
    
    // MARK: Keyboard Framing -
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            secret.contentInset = UIEdgeInsets.zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }

    // MARK: Keychain -
    
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            secret.text = text
        }
    }
    
    @objc func saveSecretMessage() {
        if !secret.isHidden {
            _ = KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
            secret.resignFirstResponder()
            secret.isHidden = true
            title = "Nothing to see here"
        }
    }
    
    // MARK: Authentication -
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [unowned self] (success, authenticationError) in
                DispatchQueue.main.async {
                    if success {
                        self.unlockSecretMessage()
                    } else {
                        // catch authentication errors
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            // no biometry error
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }



}

