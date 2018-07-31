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

class MasterViewController: UITableViewController, AuthenticationID {
      
    public lazy var qrCodeReader:QRReader = {return QRReader(controller: self)}() 
    
    var newWalletViewController: NewWalletViewController = NewWalletViewController()
    
    lazy var coverView:UIImageView = {
        let v = UIImageView(image: UIImage(named: "logo-fill-blue"))
        v.contentMode = .center
        v.alpha = 1 
        return v
    }() 
    
    var reloadTimer:Timer?
    
    @objc func update(timer:Timer)  {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()                                               
        
        statusBarHidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        
        navigationItem.rightBarButtonItem = addButton
                
        //newWalletViewController = storyboard?.instantiateViewController(withIdentifier: "NewWalletViewControllerId") as? NewWalletViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(didLaunch), name: .UIApplicationDidFinishLaunching, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLaunch), name: .UIApplicationWillEnterForeground, object: nil)
        
    }
    
    var statusBarHidden: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.5) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }
        
    private var isLaunched = false
    @objc func didLaunch(notification : NSNotification) {        
        
        isLaunched = false
        navigationController?.setNavigationBarHidden(true, animated: false)                
        UIView.cover()
        
        if !isLaunched {
            checkAuthenticate()
        }
    }
    
    var isAppearing = false
    var itemsUpdated:Int = 0
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reloadTimer?.invalidate()
        reloadTimer = nil         
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        itemsUpdated = 0
        isAppearing = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        self.isAppearing = true
        Swift.print(" viewWillAppear \(self)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        
        if self.reloadTimer == nil {
            self.reloadTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update(timer:)), userInfo: nil, repeats: true)
        }          
    }
    
    func checkAuthenticate() {
        authenticate(error: { (error) in
            if (error as! LAError).code.rawValue == LAError.biometryNotEnrolled.rawValue {
                self.reload()
            }  
            else {
                self.checkAuthenticate()
            }
        }) {    
            self.reload()
        }           
    }
    
    func reload() {        
        DispatchQueue.main.async {
            
            self.isLaunched = true
            
            if CameraQR.shared.payment != nil {
                
                if self.isAppearing {                    
                    UIAlertController(title: nil,
                                      message: "Choose target address", 
                                      preferredStyle: .alert)
                        .addAction(title: "Cancel", style: .cancel) { _ in
                            CameraQR.shared.payment = nil
                        }
                        .addAction(title: "Ok", 
                                   style: .default) { _ in
                                    if let split = self.splitViewController {
                                        let controllers = split.viewControllers
                                        let detailViewController = (controllers.last as! UINavigationController).topViewController as? DetailViewController
                                        detailViewController?.dismiss(animated: true, completion: { 
                                            
                                        })                                    
                                    }                                    
                        }
                        .present(by: self)
                }
            }
            
            UIView.uncover(complete: { 
                self.navigationController?.setNavigationBarHidden(false, animated: true)                
            })
            
            self.tableView.reloadData()
            
            if self.reloadTimer == nil {
                self.reloadTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update(timer:)), userInfo: nil, repeats: true)
            }                       
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
                self.presentInNavigationController(self.newWalletViewController, animated: true) 
            }
            .addAction(title: NSLocalizedString("Import Wallet", comment: ""), style: .default) { (alert) in
                self.qrCodeReader.open { (controller, result) in                    
                    self.reader(controller, didScanResult: result)
                }
            }
            .addAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            .present(by: self)
        
    }
    
    var currentPrivateKeyQr:String?
    var currentNameQr:String?
    
    func addWallet(name:String, privateKey:String, controller:UIViewController)  {
        
        func close(){
            currentPrivateKeyQr = nil
            currentNameQr = nil
            controller.dismiss(animated: true) {
                self.tableView.reloadData()
            }
        }   
        
        do {
            let wallet = try Wallet(name: name, privateKey: privateKey)
            
            var message = 
                NSLocalizedString("Wallet name: ", comment: "")+"\(wallet.name ?? "")\n"                 
            message +=  
                NSLocalizedString("Address: ", comment: "")+"\(wallet.publicKey ?? "")\n" 
            
            let alert = UIAlertController(title: nil, 
                                          message: message, 
                                          preferredStyle: .alert)
            
            alert.addAction(title: NSLocalizedString("Accept", comment: ""), style: .default) {  [weak self]  (allert) in                    
                do {
                    guard let json = Mapper<Wallet>().toJSONString(wallet) else {
                        alert.message = NSLocalizedString("Wallet could not be created from the secret phrase", comment: "")                                                                
                        return
                    }
                    try WalletStore.shared.keychain.set(json, key: name)
                }
                catch let error {
                    alert.message = error.localizedDescription
                }                    
                close()
                }
                .addAction(title: "Cancel", style: .cancel) { _ in
                    close()                        
                }
                .present(by: controller)                
        }
        catch let error {
            UIAlertController(title: nil, 
                              message: error.localizedDescription, 
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel) { _ in
                    close()
                }            
                .present(by: controller)
            return
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        
        if result.value.hasPrefix(Config.Shared.Wallet.privateKey){
            currentPrivateKeyQr = result.value.replacingOccurrences(of: Config.Shared.Wallet.privateKey, with: "")            
        } 
        
        if result.value.hasPrefix(Config.Shared.Wallet.name){
            currentNameQr = result.value.replacingOccurrences(of: Config.Shared.Wallet.name, with: "")            
        }              
        
        if let privateKey = currentPrivateKeyQr, 
            let name = currentNameQr {
            reader.stopScanning()                        
            addWallet(name: name, privateKey: privateKey, controller: reader)
        }
    }
    
    // MARK: - Segues    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {    
        
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let items = WalletStore.shared.items
                let item = items[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                if let value = item["value"] as? String { 
                    controller.wallet = Wallet(JSONString: value)
                }
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true                
            }
        }
    }              
}


// MARK: - Table View
extension MasterViewController {    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return WalletStore.shared.items.count > 0 ? 1 : 0 
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WalletStore.shared.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let items = WalletStore.shared.items
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
                                        
                    activiti?.stopAnimating()
                    self.itemsUpdated += 1
                    
                }, complete: { (balance) in
                    var assets = "MILE"
                    var ammounts = "0.0000"
                    for k in balance.balance.keys {
                        if chain.assets[k] == "MILE" {
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
            
            let keychain = WalletStore.shared.keychain
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
