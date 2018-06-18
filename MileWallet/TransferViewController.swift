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

class TransferViewController: Controller, QRCodeReaderViewControllerDelegate {
    
    var wallet:Wallet? 

    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var messageArea: UITextView!
        
    @IBOutlet weak var toPublicKey: UITextField!
    
    @IBOutlet weak var amount: UITextField!
        
    @IBAction func qrQodeRead(_ sender: UIButton) {
        qrQodeRead()
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
                
            
        if pkey.isEmpty {
            return
        }
        
        loaderStart()
        
        let toWallet = Wallet(name: pkey, publicKey: pkey, privateKey: "", password: nil)        
        
        Transfer.send(asset: "XDR", 
                      amount: "\(amount)", 
                      from: fromWallet, 
                      to: toWallet, 
                      error: { (error) in
                        
                        self.messageArea.text = error?.whatResponse
                        self.loaderStop()
                        
        }) { (transfer) in
            self.loaderStop()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toPublicKey.text = ""
        amount.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appear()
        self.title = wallet?.name
    }
    
    func appear()  {
        messageArea.text = ""
        amount.backgroundColor = UIColor.clear
        sendEnabled()
    }

    func qrQodeRead() {
        guard checkScanPermissions() else { return }
        
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate               = self
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let result = result {
                print("Completion with result: \(result.value) of type \(result.metadataType)")
            }
        }
        
        present(readerVC, animated: true, completion: nil)
    }
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            
            $0.reader                  = QRCodeReader(metadataObjectTypes:  [.qr], 
                                                      captureDevicePosition: .back)
            $0.showTorchButton         = true
            $0.preferredStatusBarStyle = .lightContent
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    
    // MARK: - Actions
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: { (flag) in
                                
                            }) //.openURL(settingsURL)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    // MARK: - QRCodeReader Delegate Methods
    var currentPublicKeyQr:String?
    var currentAmmountKeyQr:String?
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        
        Swift.print(" ---> \(result.value)")
        
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
        
        if result.value.hasPrefix(Config.paymentQrPrefix) {
            
            let array = result.value.replacingOccurrences(of: Config.paymentQrPrefix, with: "").components(separatedBy: ":")                
          
            if array.count < 3 {
                stop()
                return
            }
            
            toPublicKey.text = array[0] 
            amount.text = array[1] 
            
            message = "Payment Address: \(array[0])\n Amount: \(array[1] )\n Wallet name: \(array[2] )\n"             
        }
        else if result.value.hasPrefix(Config.publicKeyQrPrefix) {
            let pk = result.value.replacingOccurrences(of: Config.publicKeyQrPrefix, with: "")
            toPublicKey.text = pk            
            message = "Payment Address: \(pk)\n"             
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
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()        
        dismiss(animated: true, completion: nil)
    }
}
