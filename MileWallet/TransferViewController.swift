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

class TransferViewController: Controller {
    
    var wallet:Wallet?     
    
    var currentAssets:String = "XDR"

    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var messageArea: UITextView!
        
    @IBOutlet weak var toPublicKey: UITextField!
    
    @IBOutlet weak var amount: UITextField!
        
    @IBAction func qrQodeRead(_ sender: UIButton) {
        qrCodeReader.open { (controller, result) in
            self.reader(controller, didScanResult: result)
        }
    }
    
    @IBAction func cancelHandler(_ sender: UIButton) {
        dismiss(animated: true) {}
    }
    
    @IBAction func amountChanging(_ sender: UITextField) {
        sendEnabled() 
    }
                
    @IBAction func transferHandler(_ sender: UIButton) {
        sendEnabled()         
        transfer()
    }
    
    func sendEnabled()  {
        guard let key = toPublicKey.text, let am = amount.text else { 
            sendButton.alpha = 0.5
            sendButton.isUserInteractionEnabled = false   
            return
        }
        if key.isEmpty || am.isEmpty {
            sendButton.alpha = 0.5
            sendButton.isUserInteractionEnabled = false            
        }
        else {
            sendButton.alpha = 1
            sendButton.isUserInteractionEnabled = true            
        }
    }
    
    
    func transfer()  {
        
        guard let fromWallet = wallet else {
            return
        }
        
        guard let amount = amount.text?.floatValue else { return }
        guard let pkey = toPublicKey.text else { return }
                
            
        Swift.print("amount: \(amount) key = \(pkey)")

        if pkey.isEmpty {
            self.messageArea.text = NSLocalizedString("Target address unknown...", comment: "")
            return
        }
        
        loaderStart()
        
        let toWallet = Wallet(name: pkey, publicKey: pkey, privateKey: "", secretPhrase: nil)        
        
        print("From: \(fromWallet)")
        print("To: \(toWallet)")
        
        Transfer.send(asset: currentAssets, 
                      amount: "\(amount)", 
                      from: fromWallet, 
                      to: toWallet, 
                      error: { (error) in
                        
                        Swift.print("Error: \(String(describing: error))")
                        
                        self.messageArea.text = error?.whatResponse
                        self.loaderStop()
                        
                        
        }) { (transfer) in
            self.loaderStop()
            Swift.print("Transfer sended: \(String(describing: transfer.toJSONString()))")
            self.dismiss(animated: true) { }    
        }                
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
    }    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        amount.resignFirstResponder()
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
        self.title = wallet?.name
        if let pk = CameraQR.shared.payment?.publicKey{
            self.toPublicKey.text = pk
        }
        if let am = CameraQR.shared.payment?.amount, 
            let assets = CameraQR.shared.payment?.assets {
            self.amount.text = "\(am)"
            self.currentAssets = assets
        }
        appear()
    }
    
    func appear()  {
        messageArea.text = ""
        sendEnabled()
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
            .addAction(title: "Accept", style: .default) {  [weak self]  (allert) in
                self?.sendEnabled()
                close()
            } 
            .addAction(title: "Cancel", style: .cancel) { _ in
                close()
            }            
            .present(by: reader)        
    }
}
