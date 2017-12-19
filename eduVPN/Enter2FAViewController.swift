//
//  Enter2FAViewController.swift
//  eduVPN
//
//  Created by Johan Kool on 15/12/2017.
//  Copyright © 2017 EduVPN. All rights reserved.
//

import Cocoa

protocol Enter2FAViewControllerDelegate: class {
    func enter2FA(controller: Enter2FAViewController, enteredTwoFactor: TwoFactor)
    func enter2FACancelled(controller: Enter2FAViewController)
}

class Enter2FAViewController: NSViewController {

    enum Error: Swift.Error, LocalizedError {
        case invalidToken
        
        var errorDescription: String? {
            switch self {
            case .invalidToken:
                return NSLocalizedString("Token is invalid", comment: "")
            }
        }
        
        var recoverySuggestion: String? {
            return NSLocalizedString("Enter a valid token.", comment: "")
        }
    }
    
    weak var delegate: Enter2FAViewControllerDelegate?
    
    @IBOutlet var segmentedControl: NSSegmentedControl!
    @IBOutlet var textField: NSTextField!
    @IBOutlet var backButton: NSButton!
    @IBOutlet var doneButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change title color
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor : NSColor.white, NSAttributedStringKey.paragraphStyle : paragraphStyle]
        doneButton.attributedTitle = NSAttributedString(string: doneButton.title, attributes: attributes)
    }
    
    @IBAction func goBack(_ sender: Any) {
        delegate?.enter2FACancelled(controller: self)
    }
    
    private func validToken() -> TwoFactor? {
        let string = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        switch segmentedControl.selectedSegment {
        case 0:
            if string.count == 6, string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted, options: []) == nil {
                return .totp(string)
            } else {
                return nil
            }
        case 1:
            if string.count == 44, string.rangeOfCharacter(from: CharacterSet.lowercaseLetters.inverted, options: []) == nil {
                return .totp(string)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    @IBAction func typeChanged(_ sender: NSSegmentedControl) {
        doneButton.isEnabled = validToken() != nil
    }
    
    @IBAction func done(_ sender: Any) {
        segmentedControl.isEnabled = false
        textField.resignFirstResponder()
        textField.isEnabled = false
        doneButton.isEnabled = false
        
        guard let token = validToken() else {
            let alert = NSAlert(error: Error.invalidToken)
            alert.beginSheetModal(for: self.view.window!) { (_) in
                self.textField.isEnabled = true
            }
            return
        }
        
        delegate?.enter2FA(controller: self, enteredTwoFactor: token)
    }
}

extension Enter2FAViewController: NSTextFieldDelegate {
    
    override func controlTextDidChange(_ obj: Notification) {
        doneButton.isEnabled = validToken() != nil
    }
    
}