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
import SnapKit

class NewWalletViewController: NavigationController {
    let contentController = NewWalletViewControllerImp()     
    override func viewDidLoad() {
        super.viewDidLoad()        
        setViewControllers([contentController], animated: true)        
    }        
}

class NewWalletViewControllerImp: Controller {
   
    var nameLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.text = NSLocalizedString("Local wallet name:", comment: "")
        return l
    }() 
    
    var name: UITextField = UITextField.nameField()

    lazy var descriptionView:UITextView = { 
        let text = UITextView()
        text.isUserInteractionEnabled = false
        text.textAlignment = .left
        text.textContainer.lineBreakMode = .byWordWrapping
        text.isSelectable = false
        text.isScrollEnabled = true
        text.layer.borderWidth = 0
        text.font = UIFont.systemFont(ofSize: 12)
        text.clearsOnInsertion = false

        text.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        
        return text
    }()    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        view.addSubview(nameLabel)
        view.addSubview(name)
        view.addSubview(descriptionView)
        
        self.title = NSLocalizedString("Add New Wallet", comment: "")

        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.top.equalToSuperview().offset(navigationController!.navigationBar.frame.size.height+120)
            make.height.equalTo(44)            
        }      
        
        name.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(nameLabel.snp.width)
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.height.equalTo(60)
        }  
        
        descriptionView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(name.snp.width)
            make.top.equalTo(name.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }  
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closePayments(sender:)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addWalletHandler(_:)))
    }    
        
    @objc func closePayments(sender:Any){
        dismiss(animated: true) 
    } 
        
    @objc func addWalletHandler(_ sender: UIButton) {        
        addWallet()
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
            
            UIAlertController(title: NSLocalizedString("Wallet Error", comment: ""),
                              message:  error?.description, 
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel)
                .present(by: self)                        
        }) { (wallet) in   
                                    
            do {
                guard let json = Mapper<Wallet>().toJSONString(wallet) else {
                    UIAlertController(title: nil,
                                      message:  NSLocalizedString("Wallet could not be created from the secret phrase", comment: ""), 
                                      preferredStyle: .alert)
                        .addAction(title: "Close", style: .cancel)
                        .present(by: self)

                    return
                }
                try WalletStore.shared.keychain.set(json, key: name)
            }
            catch let error {

                UIAlertController(title: nil,
                                  message:  error.description, 
                                  preferredStyle: .alert)
                    .addAction(title: "Close", style: .cancel)
                    .present(by: self)
            }
            
            activiti.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: { 
                dimView.alpha=0
            }, completion: { (flag) in
                dimView.removeFromSuperview()
            })
            
            self.dismiss(animated: true) { }            
        }        
    }       
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        name.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        name.text = nil
    }    
}
