//
//  TransferViewController.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import JSONRPCKit
import KeychainAccess
import ObjectMapper
import QRCodeReader
import AVFoundation
import SnapKit
import MileWalletKit
import APIKit

class TransferViewController: NavigationController {    
    let contentController = TransferViewControllerImp()     
    override func viewDidLoad() {
        super.viewDidLoad()        
        setViewControllers([contentController], animated: true)        
    }        
}

class TransferViewControllerImp: Controller {
    
    var wallet:Wallet?     
    
    var currentAssets:String = "MILE"    

    lazy var toPublicKeyLabel:UILabel = {
       let l = UILabel()
        l.textAlignment = .left
        l.text = NSLocalizedString("Address: ", comment: "")
        return l
    }()
    var toPublicKey: UITextView = UITextView.hexField()

    var amountLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.text = NSLocalizedString("Amount: ", comment: "")
        return l
    }() 
    var amount: UITextField = UITextField.decimalsField()
    
    lazy var readerButton:UIButton = {
       let button = UIButton(type: UIButtonType.custom)
        button.setTitle("Read QR", for: UIControlState.normal)
        button.addTarget(self, action: #selector(qrQodeRead(_:)), for: UIControlEvents.touchUpInside)
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = UIColor.darkGray
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)                
        
        view.addSubview(toPublicKey)
        view.addSubview(toPublicKeyLabel)

        view.addSubview(amount)
        view.addSubview(amountLabel)

        view.addSubview(readerButton)

        toPublicKeyLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.top.equalToSuperview().offset(navigationController!.navigationBar.frame.size.height+40)
            make.height.equalTo(44)            
        }
        
        toPublicKey.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(toPublicKeyLabel.snp.width)
            make.top.equalTo(toPublicKeyLabel.snp.bottom).offset(20)
            make.height.equalTo(60)
        }
        
        amountLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(toPublicKey.snp.width)
            make.top.equalTo(toPublicKey.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        amount.snp.makeConstraints { (make) in
            make.centerX.equalTo(amountLabel.snp.centerX)
            make.width.equalTo(amountLabel.snp.width)
            make.top.equalTo(amountLabel.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
                
        readerButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(toPublicKey.snp.centerX)
            make.top.equalTo(amount.snp.bottom).offset(40)
            make.width.equalTo(100)
            make.height.equalTo(80)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closePayments(sender:)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(transferHandler(_:)))
    }    
    
    @objc func closePayments(sender:Any){
        dismiss(animated: true) 
    } 
    
    @objc func qrQodeRead(_ sender: UIButton) {
        qrCodeReader.open { (controller, result) in
            self.reader(controller, didScanResult: result)
        }
    }
    
    func cancelHandler(_ sender: UIButton) {
        dismiss(animated: true) {}
    }
    
    @objc func transferHandler(_ sender: UIButton) {
        transfer()
    }
        
    func transfer()  {
        
        guard let fromWallet = wallet else {
            return
        }
        
        guard let amount = amount.text?.floatValue else { return }
        guard let pkey = toPublicKey.text else { return }
                            
        if pkey.isEmpty {
            UIAlertController(title: nil,
                              message:  NSLocalizedString("Target address unknown...", comment: ""), 
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel)
                .present(by: self)
            return
        }
        
        loaderStart()
        
        let toWallet = Wallet(name: pkey, publicKey: pkey, privateKey: "", secretPhrase: nil)        
                
        Transfer.send(asset: currentAssets, 
                      amount: "\(amount)", 
                      from: fromWallet, 
                      to: toWallet, 
                      error: { error in
                                                                        
                        UIAlertController(title: NSLocalizedString("Transfer error", comment: ""),
                                          message:  error?.description, 
                                          preferredStyle: .alert)
                            .addAction(title: "Close", style: .cancel)
                            .present(by: self)
                        
                        self.loaderStop()                        
                        
        }) { (transfer) in
            self.loaderStop()          
            self.dismiss(animated: true)
        }                
    }
        
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {        
        if amount.isFirstResponder {
            amount.resignFirstResponder()
        }
        if toPublicKey.isFirstResponder {
            toPublicKey.resignFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CameraQR.shared.payment = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toPublicKey.text = ""
        amount.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = NSLocalizedString("Transfer: ", comment: "") + currentAssets
        if let pk = CameraQR.shared.payment?.publicKey{
            self.toPublicKey.text = pk
        }
        if let am = CameraQR.shared.payment?.amount, 
            let assets = CameraQR.shared.payment?.assets {
            self.amount.text = "\(am)"
            self.currentAssets = assets
        }
    }
    
    var currentPublicKeyQr:String?
    var currentAmmountKeyQr:String?
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
                
        reader.stopScanning()      

        func close(){
            self.dismiss(animated: true)
        }        

        func stop(){            
            UIAlertController(title: NSLocalizedString("Wallet Scanner Error", comment: ""), 
                              message: NSLocalizedString("QR Code is wrang", comment: ""), 
                              preferredStyle: .alert)
                .addAction(title: "Cancel", style: .cancel) { _ in
                    close()
                }            
                .present(by: reader)               
        }
                
        var message = ""
        
        if let scanned = result.value.qrCodePayment {
            let pk = scanned.publicKey
            toPublicKey.text = pk
            if let assets = scanned.assets, let _amount = scanned.amount {
                message = "Payment Address: \(pk)\n Amount: \(_amount, assets)\n Wallet name: \(scanned.name ?? "")\n"
                currentAssets = assets
                amount.text = _amount
            }            
            else {
                message = "Payment Address: \(pk)\n"             
            }
        }
        else {
            stop()
            return
        }
                     
        UIAlertController(title: nil, 
                          message: message, 
                          preferredStyle: .alert)
            .addAction(title: "Accept", style: .default) { _ in
                close()
            } 
            .addAction(title: "Cancel", style: .cancel) { _ in
                close()
            }            
            .present(by: reader)        
    }
}
