//
//  WalletContactOptions.swift
//  MileWallet
//
//  Created by denn on 28.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

class WalletContactOptions: NavigationController {
    
    public var wallet:WalletContainer?
    
    let contentController = WalletContactOptionsControllerImp()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Config.Colors.background
        setViewControllers([contentController], animated: true)
    }
}

class WalletContactOptionsControllerImp: Controller, UITextFieldDelegate {
    
    fileprivate var wallet:WalletContainer? {
        get {
            return (navigationController as? WalletContactOptions)?.wallet
        }
        set {
            (navigationController as? WalletContactOptions)?.wallet = newValue
        }
    }
    
    var contact:Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closePayments(sender:)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneHandler(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let contact = self.contact {
            title = NSLocalizedString("Send coins to", comment: "") + ": " + contact.name!
        }
        else {
            title = NSLocalizedString("New contact", comment: "")
        }
        if let a = wallet?.attributes{
            (navigationController as? NavigationController)?.titleColor = UIColor(hex: a.color)
        }
    }
    
    @objc private func closePayments(sender:Any){
        dismiss(animated: true)
    }
    
    @objc private func doneHandler(_ sender: UIButton) {
//        if let wallet = self.wallet?.wallet {
//            self.updateWallet(wallet: wallet)
//        }
//        else {
//            addWallet()
//        }
    }
}
