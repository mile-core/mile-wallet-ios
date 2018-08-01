//
//  PasswordScreen.swift
//  MileWallet
//
//  Created by denn on 01.08.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

import UIKit
import SmileLock
import MileWalletKit
import KeychainAccess

class PasscodeScreen: UIViewController {
    
    @IBOutlet weak var passwordStackView: UIStackView!
    
    @IBOutlet weak var passwordTitle: UILabel!
    
    public var settingsMode = false {
        didSet{
            passCodeConfirmationStage = 0
        }
    }
    
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = PasscodeStrore.shared.passcodeLength
    
    private var firstView:UIView?
    override func viewDidLoad() {
        
        firstView = UIApplication.shared.keyWindow?.subviews.first
        firstView?.alpha = 0
        
        super.viewDidLoad()
        
        view.backgroundColor = Config.Colors.background
        
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.passwordDotView.tintColor = Config.Colors.defaultColor
        passwordContainerView.deleteButtonLocalizedTitle = NSLocalizedString("Delete", comment: "")
        
        passwordContainerView.tintColor = Config.Colors.caption
        passwordContainerView.highlightedColor = Config.Colors.defaultColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if settingsMode {
            firstView?.alpha = 1
        }
        super.viewWillAppear(animated)
        passwordTitle.text = NSLocalizedString("Enter Passcode", comment: "")
        passwordContainerView.touchAuthenticationEnabled = !settingsMode
        passwordContainerView.clearInput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstView?.alpha = 1
    }
    
    fileprivate var passCodeConfirmationStage = 0
    fileprivate var newPasscode:String? = nil
}

extension PasscodeScreen: PasswordInputCompleteProtocol {
    
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if validation(input) {
            validationSuccess()
        } else {
            validationFail()
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
}

private extension PasscodeScreen {
    
    func validation(_ input: String) -> Bool {
        
        if settingsMode && passCodeConfirmationStage == 0 {
            
            if !PasscodeStrore.shared.isRegistered {
                newPasscode = input
                return true
            }
            
            return false
        }
        else if settingsMode && passCodeConfirmationStage == 1 {
            if let passcode = newPasscode, passcode == input {
                newPasscode = nil
                
                UIAlertController(title: nil,
                                  message: NSLocalizedString("Are you sure you remember the passcode?", comment: ""), preferredStyle: .actionSheet)
                    .addAction(title: NSLocalizedString("No", comment: ""), style: .cancel)
                    .addAction(title: NSLocalizedString("Yes", comment: ""), style: .default) { (action) in
                        PasscodeStrore.shared.reset(old: passcode, new: input)
                        self.dismiss(animated: true)
                    }
                    .present(by: self)
                
                return true
            }
        }
        
        return PasscodeStrore.shared.validate(code: input)
    }
    
    func validationSuccess() {
        if settingsMode && passCodeConfirmationStage == 0 {
            passCodeConfirmationStage = 1
            UIView.animate(withDuration: Config.animationDuration,
                           delay: 0.2,
                           options: [],
                           animations: {
                            self.passwordTitle.text = NSLocalizedString("Confirm Passcode", comment: "")
                            self.passwordContainerView.clearInput()
            })
        }
        else if !settingsMode {
            dismiss(animated: true) {
                self.settingsMode = false
            }
        }
    }
    
    func validationFail() {
        if settingsMode && passCodeConfirmationStage == 1 {
            passCodeConfirmationStage = 0
            UIView.animate(withDuration: Config.animationDuration,
                           delay: 0.2,
                           options: [],
                           animations: {
                            self.passwordTitle.text = NSLocalizedString("Enter Passcode", comment: "")
                            self.passwordContainerView.clearInput()
            })
        }
        passwordContainerView.wrongPassword()
        passCodeConfirmationStage = 0
    }
}
