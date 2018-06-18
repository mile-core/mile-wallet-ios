//
//  DetailViewController.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import APIKit
import JSONRPCKit
import KeychainAccess
import ObjectMapper
import EFQRCode 

class DetailViewController: Controller {
    
    var keychain:Keychain {
        return Keychain(service: Config.walletService).synchronizable(Config.isWalletKeychainSynchronizable)
    }
    
    private var chainInfo:Chain?
    
    func mileInfoUpdate(error: ((_ error: SessionTaskError?)-> Void)?=nil, 
                        complete:@escaping ((_ chain:Chain)->Void))  {        
        
        if chainInfo == nil {
            Chain.update(error: { (e) in
                
                error?(e)
                
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
    
    var wallet:Wallet? 
    
    @IBOutlet weak var transferButton: UIButton!
    
    @IBOutlet weak var qrQode: UIImageView!
    
    @IBOutlet weak var address: UITextView!
    
    @IBOutlet weak var xdrAmountLable: UILabel!
    
    @IBOutlet weak var mileAmountLable: UILabel!
    
    
    var toggelPublicKey:Bool = true {        
        didSet{
            drawQrCode()
        }
    }    
    
    @IBAction func print(_ sender: UIButton) {
        
        UIAlertController(title: nil, 
                          message: nil, 
                          preferredStyle: .actionSheet)
            .addAction(title: NSLocalizedString("Print Payment Ticket", comment: ""), style: .default) { (allert) in
                self.fillPayments()
            } 
            .addAction(title: NSLocalizedString("Print Wallet Secret Papper", comment: ""), style: .default) { (allert) in
                self.printSecretPaper() 
            } 
            .addAction(title: "Cancel", style: .cancel) 
            .present(by: self)          
    }
    
    @IBAction func toggleQRCodeKeys(_ sender: UISegmentedControl) {
        toggelPublicKey = !toggelPublicKey
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    var reloadTimer:Timer? 
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTimer?.invalidate()
        reloadTimer = nil
    }    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)     
        
        configureView()
        drawQrCode()       

        reloadTimer?.invalidate()
        reloadTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update(timer:)), userInfo: nil, repeats: true)
    }
    
    @objc func update(timer:Timer?)  {
        
        guard let w = wallet, let chain = chainInfo else {return}
        
        Balance.update(wallet: w, error: { (error) in
            
            Swift.print("Balance update error: \(String(describing: error?.whatResponse))")
            
            self.activiti1.stopAnimating()
            self.activiti2.stopAnimating()
            
        }, complete: { (balance) in
            
            self.xdrAmountLable.text = "0.0000"
            self.mileAmountLable.text = "0.0000"
            
            self.activiti1.stopAnimating()
            self.activiti2.stopAnimating()
            
            for k in balance.balance.keys {
                if chain.assets[k] == "XDR" {
                    self.xdrAmountLable.text = String(format: "%.4f", (Float(balance.balance[k] ?? "0") ?? 0.0))
                }
                else if chain.assets[k] == "MILE" {
                    self.mileAmountLable.text = String(format: "%.4f", (Float(balance.balance[k] ?? "0") ?? 0.0))
                }
            }                                               
        })              
    }
    
    
    func drawQrCode()  {
        var content:String?
        var qrImage:UIImage?
        
        guard let name = wallet?.name else { return } 
        
        if toggelPublicKey {
            content = wallet?.publicKey
            qrImage = wallet?.publicKeyQRImage
        }
        else {
            
            DispatchQueue.global().async {
                do {
                    _ = try self.keychain
                        .authenticationPrompt("Authenticate Private Key")
                        .get(name)                    
                } catch let error {
                    Swift.print("error: \(String(describing: error))")
                    // Error handling if needed...
                }
            }
            
            content = wallet?.privateKey
            qrImage = wallet?.privateKeyQRImage
        }
        
        address.text = content
        qrQode.image = qrImage      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    lazy var activiti1:UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        a.hidesWhenStopped = true   
        self.xdrAmountLable.addSubview(a)
        a.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }    
        return a
    }() 
    
    lazy var activiti2:UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        a.hidesWhenStopped = true        
        self.mileAmountLable.addSubview(a)
        a.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return a
    }() 
        
    func configureView() {   
        
        self.title = wallet?.name        
        
        activiti1.startAnimating()                     
        activiti2.startAnimating()                                        
                    
        self.mileInfoUpdate(error: { (error) in
            
            self.activiti1.stopAnimating()
            self.activiti2.stopAnimating()
            
            Swift.print("Info update error: \(String(describing: error?.whatResponse))")
            
        }){ (chain) in
            
            self.chainInfo = chain
            
            self.update(timer: nil)
            
        }
    }
    
    lazy var paymentController:UINavigationController = {
        let u = UINavigationController(rootViewController: PaymentController())
        let close = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closePayments(sender:)))
        let ok = UIBarButtonItem(title: NSLocalizedString("Print", comment: ""), style: .plain, target: self, action: #selector(self.printPayments(sender:)))
        u.topViewController?.navigationItem.title = NSLocalizedString("Payment Ticket", comment: "")
        u.topViewController?.navigationItem.leftBarButtonItem = close
        u.topViewController?.navigationItem.rightBarButtonItem = ok
        return u
    }()
    
    func fillPayments() {     
        (paymentController.topViewController as? PaymentController)?.wallet = wallet 
        present(paymentController, animated: true)
    }
    
    @objc func closePayments(sender:Any){
        paymentController.dismiss(animated: true) { 
            
        }
    }
    
    @objc func printPayments(sender:Any){
        let pc = (paymentController.topViewController as? PaymentController)
        self.printPDF(wallet: self.wallet, 
                      formater: { return HTMLTemplate.getAmount(wallet:$0, amount: pc?.amount ?? "0.0") }
        ){ (controller, completed, error) in                                            
            if completed {
                self.paymentController.dismiss(animated: true) 
            }
        } 
    }
    
    func printSecretPaper() {                            
        printPDF(wallet: wallet, 
                 formater: { return HTMLTemplate.get(wallet:$0) }, 
                 complete: nil)                    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transfer" {
            (segue.destination as! TransferViewController).wallet = wallet
        }
    }                      
}
