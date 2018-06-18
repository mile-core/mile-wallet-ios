//
//  NewWalletViewController.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import APIKit
import JSONRPCKit
import KeychainAccess
import ObjectMapper

extension JSONRPCKit.JSONRPCError {
    var what:String {                
        switch self {
        case .responseError(_, let message, _):
            return message
        case .responseNotFound(_,_):
            return NSLocalizedString("Response not found...", comment: "")
        case .resultObjectParseError(_):
            return NSLocalizedString("Result object parse error", comment: "")
        case .unsupportedVersion(_):
            return NSLocalizedString("API Unsupported version", comment: "")
        case .unexpectedTypeObject(_), .missingBothResultAndError(_), .nonArrayResponse(_), .errorObjectParseError(_):
            return NSLocalizedString("Result object parse fail", comment: "")
        }
    }    
}

extension SessionTaskError {
    var whatResponse:String? {        
        let error = self         
        var jsonrpcError:JSONRPCKit.JSONRPCError?
        
        switch error {
        case .responseError(let error), .connectionError(let error), .requestError(let error): 
            jsonrpcError = error as? JSONRPCKit.JSONRPCError               
        }
        
        guard let responseError = jsonrpcError else { return nil }
        
        return responseError.what
    }    
}

class NewWalletViewController: UIViewController {
        
    var keychain:Keychain {
        return Keychain(service: Config.walletService).synchronizable(Config.isWalletKeychainSynchronizable)
    }
    
    @IBOutlet weak var createNewButton: UIButton!
    
    @IBOutlet weak var messageArea: UITextView!
    
    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var secretPhrase: UITextField!
        
    @IBOutlet weak var secretPhraseRepeted: UITextField!
    
    @IBAction func cancelHandler(_ sender: UIButton) {
        dismiss(animated: true) {}
    }
    
    func okEnabled(enable:Bool)  {
        if !enable {
            createNewButton.alpha = 0.5
            createNewButton.isUserInteractionEnabled = false
        }
        else {
            createNewButton.alpha = 1
            createNewButton.isUserInteractionEnabled = true            
        }
    }
    
    @IBAction func secretChanging(_ sender: UITextField) {
        guard let text = sender.text else {
            appear()
            okEnabled(enable: false)
            return             
        }
        if sender === secretPhrase {
            if text.count < 6 {
                progress.trackTintColor = UIColor.red
            }
            else if text.count >= 6 && text.count <= 10 {
                progress.trackTintColor = UIColor.orange
            }
            else if text.count > 10 {
                progress.trackTintColor = UIColor.green
            }
        }
        if secretPhrase.text != secretPhraseRepeted.text {
            secretPhraseRepeted.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            okEnabled(enable: false)
        }
        else {
            secretPhraseRepeted.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            okEnabled(enable: true)
        }          
        guard let nameWallet = name.text else {
            okEnabled(enable: false)
            return
        }  
        if nameWallet.isEmpty {
            okEnabled(enable: false)
        }
    }
    
    @discardableResult func testSecret() -> Bool {
        guard let phrase  = secretPhrase.text else { return false }
        guard let phrase2 = secretPhraseRepeted.text else { return false }
        guard let name = name.text else { return false }
        
        if phrase != phrase2 || name.isEmpty || phrase.count < 6 {
            okEnabled(enable: false)
            return false
        }
        
        okEnabled(enable: true)
        
        return true
    }
    
    @IBAction func secretChanged(_ sender: UITextField) {
        testSecret()
    }
    
    
    @IBAction func addWalletBySecret(_ sender: UITextField) {
        guard let text = name.text else { return }
        if sender === secretPhraseRepeted && text.count > 0{
            sender.resignFirstResponder()
        }        
    }
    
    @IBAction func addWalletHandler(_ sender: UIButton) {        
        addWallet()
    }
    
    func addWallet()  {
    
        guard testSecret() else { return }
        
        guard let phrase  = secretPhrase.text else { return }
        guard let name = name.text else { return }
                       
        let activiti = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        dimView.alpha = 0
        
        view.addSubview(dimView)
        
        activiti.hidesWhenStopped = true        
        activiti.startAnimating()        
        dimView.addSubview(activiti)
        
        dimView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.1) { 
            dimView.alpha = 1
        }
        
        activiti.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        
        Wallet.create(name: name, secretPhrase: phrase, error: { error in             
            
            self.messageArea.text = error?.whatResponse            
            
        }) { (wallet) in   
            
            self.messageArea.text = nil
            
            let keychain = self.keychain            
            
            //DispatchQueue.global().async {
            do {
                guard let json = Mapper<Wallet>().toJSONString(wallet) else {
                    self.messageArea.text = NSLocalizedString("Wallet could not be created from the secret phrase", comment: "")
                    return
                }
                try keychain.synchronizable(Config.isWalletKeychainSynchronizable)
                    //.accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    //.authenticationPrompt("Authenticate to update your access token")
                    .set(json, key: name)
            }
            catch let error {
                self.messageArea.text = error.localizedDescription                                              
            }
            //}
            
            activiti.stopAnimating()
            UIView.animate(withDuration: 0.2, animations: { 
                dimView.alpha=0
            }, completion: { (flag) in
                dimView.removeFromSuperview()
            })
            
            self.dismiss(animated: true) { }            
        }        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appear()
        name.text = nil
    }
    
    func appear()  {
        okEnabled(enable: false)
        messageArea.text = ""
        secretPhraseRepeted.text = nil
        secretPhrase.text = nil
        progress.trackTintColor = UIColor.gray
        secretPhraseRepeted.backgroundColor = UIColor.clear
        secretPhrase.backgroundColor = UIColor.clear
    }
}
