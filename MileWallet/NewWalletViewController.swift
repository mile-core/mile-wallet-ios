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
import MileWalletKit

class NewWalletViewController: Controller {
                
    var keychain:Keychain {
        return Keychain(service: Config.walletService).synchronizable(Config.isWalletKeychainSynchronizable)
    }    
    
    @IBOutlet weak var messageArea: UITextView!
    
    @IBOutlet weak var createNewButton: UIButton!
        
    @IBOutlet weak var name: UITextField!
    
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
            
    
    @IBAction func addWalletHandler(_ sender: UIButton) {        
        addWallet()
    }
    
    @IBAction func nameChanging(_ sender: UITextField) {
        if let c = sender.text?.count, c >= 3 {
            okEnabled(enable: true)
        } 
        else {
            okEnabled(enable: false)
        }
    }
    
    func addWallet()  {
            
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
        
        
        Wallet.create(name: name, secretPhrase: nil, error: { error in             
            
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        name.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appear()
        name.text = nil
    }
    
    func appear()  {
        messageArea.text = ""           
        okEnabled(enable: false)
    }
}
