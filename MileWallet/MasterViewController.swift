//
//  MasterViewController.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import APIKit
import JSONRPCKit
import KeychainAccess
import SnapKit
import QRCodeReader
import ObjectMapper
import MileWalletKit
import LocalAuthentication

class MasterViewController: UITableViewController {
    
    public lazy var qrCodeReader:QRReader = {return QRReader(controller: self)}() 

    let localAuthenticationContext = LAContext()
    
    var detailViewController: DetailViewController? = nil
    var newWalletViewController: NewWalletViewController? = nil
    
    var reloadTimer:Timer?
    
    var keychain:Keychain {
        return Keychain(service: Config.walletService).synchronizable(Config.isWalletKeychainSynchronizable)
        //.authenticationPrompt(" ???") //.synchronizable(Config.isWalletKeychainSynchronizable)
    }
    
    var keychainItems:[[String : Any]] {
        return keychain.authenticationPrompt(" ???").allItems()
    }
    
    @objc func update(timer:Timer)  {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()                                               
        
        authenticationWithTouchID()

        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        
        navigationItem.rightBarButtonItem = addButton
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        newWalletViewController = storyboard?.instantiateViewController(withIdentifier: "NewWalletViewControllerId") as? NewWalletViewController                             
    }
    
    var isAppeared = false
    var itemsUpdated:Int = 0

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reloadTimer?.invalidate()
        reloadTimer = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        itemsUpdated = 0
        isAppeared = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        isAppeared = true
        tableView.reloadData()
        
        if reloadTimer == nil {
            reloadTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update(timer:)), userInfo: nil, repeats: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private var chainInfo:Chain?
    
    func mileInfoUpdate(complete:@escaping ((_ chain:Chain)->Void))  {        
        
        if chainInfo == nil {
            Chain.update(error: { (error) in
                
            }) { (chain) in
                self.chainInfo = chain
                complete(self.chainInfo!)
            }
        }
        
        guard let chain = chainInfo else {
            return
        }
        
        complete(chain)
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
                
        UIAlertController(title: nil, 
                          message: nil, 
                          preferredStyle: .actionSheet)
            .addAction(title: NSLocalizedString("New Wallet", comment: ""), style: .default) { (alert) in
                self.present(self.newWalletViewController!, animated: true) { }
            }
            .addAction(title: NSLocalizedString("Import Wallet", comment: ""), style: .default) { (alert) in
                self.qrCodeReader.open { (controller, result) in
                    self.reader(controller, didScanResult: result)
                }
            }
            .addAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            .present(by: self)
        
    }

    var currentPublicKeyQr:String?
    var currentPrivateKeyQr:String?
    var currentNameQr:String?
      
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        
        if result.value.hasPrefix(Config.privateKeyQrPrefix){
            currentPrivateKeyQr = result.value.replacingOccurrences(of: Config.privateKeyQrPrefix, with: "")            
        } 

        if result.value.hasPrefix(Config.publicKeyQrPrefix){
            currentPublicKeyQr = result.value.replacingOccurrences(of: Config.publicKeyQrPrefix, with: "")            
        } 
                
        if result.value.hasPrefix(Config.nameQrPrefix){
            currentNameQr = result.value.replacingOccurrences(of: Config.nameQrPrefix, with: "")            
        }
        
        func close(){
            reader.dismiss(animated: true) 
        }   
        
        if let privateKey = currentPublicKeyQr, 
            let publicKey = currentPublicKeyQr,
            let name = currentNameQr {
            reader.stopScanning()
         
            let wallet = Wallet(name: name, publicKey: publicKey, privateKey: privateKey, password: nil)
            
            UIAlertController(title: nil, 
                              message: "Wallet name: \(name)\nPublic Key: \(publicKey)", 
                              preferredStyle: .alert)
                
                .addAction(title: "Accept", style: .default) {  [weak self]  (allert) in                    
                    do {
                        guard let json = Mapper<Wallet>().toJSONString(wallet) else {
                            //Swift.print("Keychain error: \(error)")
                            let mess = NSLocalizedString("Wallet could not be created from the secret phrase", comment: "")
                            Swift.print("Keychain error: \(mess)")
                            return
                        }
                        try self?.keychain.set(json, key: name)
                    }
                    catch let error {
                        Swift.print("Keychain error: \(error)")
                        //self.messageArea.text = error.localizedDescription
                    }                    
                    close()
                } 
                .addAction(title: "Cancel", style: .cancel) { _ in
                    close()
                }            
                .present(by: reader)    
            
            currentPrivateKeyQr = nil
            currentNameQr = nil
            currentNameQr = nil
        }
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {    
        
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let items = self.keychainItems
                let item = items[indexPath.row]
                                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController

                if let value = item["value"] as? String { 
                    controller.wallet = Wallet(JSONString: value)
                }

                detailViewController?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                detailViewController?.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.keychainItems.count > 0 ? 1 : 0 
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.keychainItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                
        let items = self.keychainItems
        let item = items[indexPath.row]
                
        let titleLabel = tableView.viewWithTag(999) as! UILabel
        let assetNameLabel = tableView.viewWithTag(1000) as! UILabel
        let amountLabel = tableView.viewWithTag(1001) as! UILabel
        
        titleLabel.text = item["key"] as? String
                
        if assetNameLabel.text == nil {
            assetNameLabel.text = "-"
        }
        if amountLabel.text == nil || itemsUpdated < items.count { 
            amountLabel.text = ""
        }
        
        var activiti:UIActivityIndicatorView?
        
        if itemsUpdated < items.count {
            activiti = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activiti?.hidesWhenStopped = true
            
            activiti?.startAnimating()
            
            cell.contentView.addSubview(activiti!)
            
            activiti?.snp.makeConstraints { (make) in
                make.height.equalTo(amountLabel)
                make.width.equalTo(amountLabel)
                make.center.equalTo(amountLabel.snp.center)
            }
        } 
        
        mileInfoUpdate { (chain) in
            if let value =  item["value"] as? String, 
                let wallet = Wallet(JSONString: value) {    
                
                Balance.update(wallet: wallet, error: { (error) in
                    
                    Swift.print("Get.... Error: \(String(describing: error))")
                    
                    activiti?.stopAnimating()
                    self.itemsUpdated += 1
                    
                }, complete: { (balance) in
                    var assets = "XDR"
                    var ammounts = "0.0000"
                    for k in balance.balance.keys {
                        if chain.assets[k] == "XDR" {
                            assets = chain.assets[k] ?? "?"
                            let a = String(format: "%.4f", (Float(balance.balance[k] ?? "0") ?? 0.0))
                            ammounts = a
                        }
                    }    
                                        
                    assetNameLabel.text = assets
                    amountLabel.text = ammounts

                    activiti?.stopAnimating()
                    self.itemsUpdated += 1
                })
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
                
        if editingStyle == .delete {
            
            let keychain = self.keychain
            let items = keychain.allItems()
            guard let key = items[indexPath.row]["key"] as? String else { return }
            
            do{ 
                try keychain.remove(key)
            }
            catch let error {
                Swift.print("Error: remove: \(error)")
            }
            
            if items.count == 1 {
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        } 
    }
}

extension MasterViewController {
    
    func authenticationWithTouchID() {
        
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        let reasonString = "To access the secure data"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    //TODO: User authenticated successfully, take appropriate action
                    
                    print(" ... success ...")
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    
                    print("evaluateError : \(evaluateError)")

                    guard let error = evaluateError else {
                        return
                    }
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
}

