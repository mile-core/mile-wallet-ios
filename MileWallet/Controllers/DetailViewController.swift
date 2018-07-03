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
import MileWalletKit

class DetailViewController: Controller {
    
    private var chainInfo:Chain?
    
    var currentAssets:String = "MILE"
    
    func mileInfoUpdate(error: ((_ error: Error?)-> Void)?=nil, 
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
    
    
    @IBAction func toggleQRCodeKeys(_ sender: UISegmentedControl) {
        toggelPublicKey = !toggelPublicKey
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareWalletInfo(_:)))         
        navigationItem.rightBarButtonItem = addButton        
        
        let sendXdrTouch  = UITapGestureRecognizer(target: self, action: #selector(transferXdr(gesture:)))
        xdrAmountLable.isUserInteractionEnabled = true
        xdrAmountLable.addGestureRecognizer(sendXdrTouch)
                
        let sendMileTouch = UITapGestureRecognizer(target: self, action: #selector(transferMile(gesture:)))
        mileAmountLable.isUserInteractionEnabled = true
        mileAmountLable.addGestureRecognizer(sendMileTouch)
        
        configureView()            
        NotificationCenter.default.addObserver(self, selector: #selector(didLaunch(notification:)), name: Notification.Name("CameraQRDidUpdate"), object: nil)        
    }
    
    @objc func transferXdr(gesture:UITapGestureRecognizer) {
        currentAssets = "XDR"
        transferAsset()
    }
    
    @objc func transferMile(gesture:UITapGestureRecognizer) {
        currentAssets = "MILE"
        transferAsset()
    }
    
    func transferAsset() {
        
        UIAlertController(title: nil, 
                          message: nil, 
                          preferredStyle: .actionSheet)
            .addAction(title: NSLocalizedString("Send coins", comment: ""), style: .default) { (alert) in                
                self.editTransfer()
            } 
            .addAction(title: NSLocalizedString("Print Payment Ticket", comment: ""), style: .default) { (alert) in
                self.fillPayments()
            } 
            .addAction(title: NSLocalizedString("Send Payment Link", comment: ""), style: .default, handler: { (alert) in
                self.sendLink()
            })
            .addAction(title: "Cancel", style: .cancel) 
            .present(by: self)                          
    }
    
    @objc func didLaunch(notification : NSNotification) {
        if CameraQR.shared.payment != nil && isAppeared {
            editTransfer()
        }
    }
    
    var reloadTimer:Timer? 
    
    var isAppeared = false
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTimer?.invalidate()
        reloadTimer = nil
        isAppeared = false
    }        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)     
        
        configureView()
        drawQrCode()       

        reloadTimer?.invalidate()
        reloadTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update(timer:)), userInfo: nil, repeats: true)
        
        isAppeared = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()   
        Swift.print(" ##### viewDidAppear  Detail \(self): \(String(describing: CameraQR.shared.payment))")
        if CameraQR.shared.payment != nil {
            editTransfer()
        }
    }
    
    @objc func update(timer:Timer?)  {
        
        guard let w = wallet, let chain = chainInfo else {return}
        
        Balance.update(wallet: w, error: { (error) in
            
            UIAlertController(title: NSLocalizedString("Balance error", comment: ""),
                              message:  error?.description, 
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel)
                .present(by: self)
            
            self.stopActivities()
            
        }, complete: { (balance) in
            
            self.xdrAmountLable.text = "0.0000"
            self.mileAmountLable.text = "0.0000"
            
            self.stopActivities()
            
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
            qrImage = wallet?.publicKeyQr
        }
        else {
            
            DispatchQueue.global().async {
                do {
                    _ = try Store.shared.keychain
                        .authenticationPrompt("Authenticate Private Key")
                        .get(name)                    
                } catch let error {
                    UIAlertController(title: NSLocalizedString("Keychain error", comment: ""),
                                      message:  error.description, 
                                      preferredStyle: .alert)
                        .addAction(title: "Close", style: .cancel)
                        .present(by: self)
                }
            }
            
            content = wallet?.privateKey
            qrImage = wallet?.privateKeyQr
        }
        
        address.text = content
        qrQode.image = qrImage      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func activityLoader(place:UIView)  -> UIActivityIndicatorView {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        a.hidesWhenStopped = true   
        place.addSubview(a)
        a.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }    
        return a        
    }
    
    func startActivities()  {
        for a in activities { a.startAnimating() }
    }            
    
    func stopActivities()  {
        for a in activities { a.stopAnimating() }
    }        
    
    lazy var activities:[UIActivityIndicatorView] = [self.activityLoader(place: self.xdrAmountLable),
                                                     self.activityLoader(place: self.mileAmountLable)]
        
    func configureView() {   
        
        self.title = wallet?.name        
        
        startActivities()
                            
        self.mileInfoUpdate(error: { (error) in
            
            self.stopActivities()

            UIAlertController(title: NSLocalizedString("MILE blockchain error", comment: ""),
                              message:  error?.description, 
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel)
                .present(by: self)
            
        }){ (chain) in            
            self.chainInfo = chain            
            self.update(timer: nil)            
        }
    }
    
    func sendLink()  {
        guard var url = wallet?.paymentLink(assets: currentAssets, amount: "0") else { return }
        url = url.replacingOccurrences(of: "https:", with: Config.appSchema)
        let activity = UIActivityViewController(activityItems: ["Please send your coins to the address", url], applicationActivities:nil)
        present(activity, animated: true) 
    }
    
    lazy var transferController:TransferViewController = {
        return TransferViewController()
    }()
    
    func editTransfer() {
        transferController.contentController.currentAssets = self.currentAssets
        transferController.contentController.wallet = self.wallet
        present(transferController, animated: true)
    }
    
    lazy var paymentController:PaymentController = {
        return PaymentController()
    }()
    
    func fillPayments() {     
        paymentController.contentController.currentAssets = self.currentAssets
        paymentController.contentController.wallet = wallet
        present(paymentController, animated: true)
    }
    
    func printSecretPaper() {
        loaderStart()
        Printer.shared.printPDF(wallet: wallet, 
                 formater: { return HTMLTemplate.get(wallet:$0) }, 
                 complete: { _,_,_ in
                    self.loaderStop()
        })                    
    }
}


// MARK: - Send WalletInfo info
extension DetailViewController {
    
    @objc func shareWalletInfo(_ sender: Any) {        
        UIAlertController(title: nil, 
                          message: nil, 
                          preferredStyle: .actionSheet)
            .addAction(title: NSLocalizedString("Print Wallet Secret Papper", comment: ""), style: .default) { (alert) in
                self.printSecretPaper() 
            } 
            .addAction(title: "Cancel", style: .cancel) 
            .present(by: self)          
    }
}
