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
    
    public var didVerifyHandler: ((_ controller:PasscodeScreen)->Void)?
    
    public var settingsMode = false {
        didSet{
            passCodeConfirmationStage = 0
        }
    }
    
    public static var isUnlocked:Bool = false
    public static var isPresenting = false

    private var passwordContainerView: PasswordContainerView!
    public let kPasswordDigit = PasscodeStrore.shared.passcodeLength
    
    
    private var firstView:UIView?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = Config.Colors.defaultColor
      
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.passwordDotView.tintColor = UIColor.white
        passwordContainerView.deleteButtonLocalizedTitle = NSLocalizedString("Delete", comment: "")
        
        passwordContainerView.tintColor = UIColor.white
        passwordContainerView.highlightedColor = UIColor.white
        
        passwordContainerView.passwordInputViews.forEach {
            $0.textColor = UIColor.white
            $0.highlightTextColor = Config.Colors.passCodeDigit
            $0.labelFont = Config.Fonts.passCodeDigit
            $0.borderColor = Config.Colors.passCodeDigit
            $0.circleBackgroundColor = Config.Colors.passCodeDigit
            $0.highlightBackgroundColor = UIColor.white
        }

        passwordTitle.adjustsFontSizeToFitWidth = true
        passwordTitle.minimumScaleFactor = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PasscodeScreen.isPresenting = true
        super.viewWillAppear(animated)
        
        passwordContainerView.alpha = 1
        passwordContainerView.isUserInteractionEnabled = true
        passwordTitle.text = NSLocalizedString("Enter Passcode", comment: "")
        passwordContainerView.touchAuthenticationEnabled = !settingsMode
        passwordContainerView.clearInput()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)

        if let lastDate = UserDefaults.standard.object(forKey: lockedKey) as? Date {
            let left = (Date().timeIntervalSince1970 - lastDate.timeIntervalSince1970)
            if left < Config.passcodeAttemptsTimer {
                lockScreen()
                
                lockTimer?.invalidate()
                lockTimer = Timer.scheduledTimer(timeInterval: left,
                                                 target: self,
                                                 selector: #selector(unlockTimerHandler(timer:)),
                                                 userInfo: nil,
                                                 repeats: false)
            }
            else {
                failsCounter = 0
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PasscodeScreen.isPresenting = false
    }
    
    fileprivate var passCodeConfirmationStage = 0
    fileprivate var newPasscode:String? = nil
    fileprivate var _isUnlocked:Bool = false
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            completion?()
        }
    }
    
    fileprivate var failsCounter = 0
    fileprivate var lockTimer:Timer?
    fileprivate let lockedKey = "wallet-is-locked"
}

extension PasscodeScreen: PasswordInputCompleteProtocol {
    
    @objc func unlockTimerHandler(timer:Timer) {
        timer.invalidate()
        
        UIView.animate(withDuration: Config.animationDuration, animations: {
            self.passwordTitle.alpha = 0
        }) { (flag) in
            self.failsCounter = 0
            self.passwordContainerView.isUserInteractionEnabled = true
            self.passwordTitle.text = NSLocalizedString("Enter Passcode", comment: "")
            UIView.animate(withDuration: Config.animationDuration) {
                self.passwordTitle.alpha = 1
                self.passwordContainerView.alpha = 1
                self.passwordContainerView.wrongPassword()
            }
        }
    }
    
    
    fileprivate func lockScreen(){
        
        lockTimer?.invalidate()
        lockTimer = Timer.scheduledTimer(timeInterval: Config.passcodeAttemptsTimer,
                                         target: self,
                                         selector: #selector(unlockTimerHandler(timer:)),
                                         userInfo: nil,
                                         repeats: false)
        
        passwordContainerView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: Config.animationDuration, animations: {
            self.passwordTitle.alpha = 0
        }) { (flag) in
            self.passwordTitle.text = NSLocalizedString("Wallet is disabled try again in ", comment: "") + "\(Int(Config.passcodeAttemptsTimer)) " + NSLocalizedString("seconds", comment: "")
            UIView.animate(withDuration: Config.animationDuration) {
                self.passwordTitle.alpha = 1
                self.passwordContainerView.alpha = 0.7
            }
        }
    }
    
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if validation(input) {
            failsCounter = 0
            validationSuccess()
        } else {
            
            if Config.passcodeAttemptsLimit <= failsCounter {
                UserDefaults.standard.set(Date(), forKey: self.lockedKey)
                UserDefaults.standard.synchronize()
                self.lockScreen()
                return
            }
            
            failsCounter += 1
            
            validationFail()
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            PasscodeScreen.isUnlocked = false
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
        PasscodeScreen.isUnlocked = true

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
        self.didVerifyHandler?(self)
    }
    
    func validationFail() {
        PasscodeScreen.isUnlocked = false
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
