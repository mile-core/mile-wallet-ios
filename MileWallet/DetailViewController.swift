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
    
    var currentAssets:String = "XDR"
    
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
        if let c = storyboard?.instantiateViewController(withIdentifier: "TransferViewControllerId") as? TransferViewController {
            c.currentAssets = currentAssets
            c.wallet = wallet
            navigationController?.pushViewController(c, animated: true)
        }
    }
    
    @objc func transferMile(gesture:UITapGestureRecognizer) {
        currentAssets = "MILE"
        if let c = storyboard?.instantiateViewController(withIdentifier: "TransferViewControllerId") as? TransferViewController {
            c.currentAssets = currentAssets
            c.wallet = wallet
            navigationController?.pushViewController(c, animated: true)
        }
    }
    
    @objc func didLaunch(notification : NSNotification) {
        if CameraQR.shared.payment != nil && isAppeared {
            transferButton.sendActions(for: .touchUpInside)
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
            transferButton.sendActions(for: .touchUpInside)
        }
    }
    
    @objc func update(timer:Timer?)  {
        
        guard let w = wallet, let chain = chainInfo else {return}
        
        Balance.update(wallet: w, error: { (error) in
            
            Swift.print("Balance update error: \(String(describing: error?.whatResponse))")
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
                        
            Swift.print("Info update error: \(String(describing: error?.whatResponse))")
            
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
                      formater: { return HTMLTemplate.getAmount(wallet:$0, assets: self.currentAssets, amount: pc?.amount ?? "0.0") }
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
            let controller = (segue.destination as! TransferViewController)
            controller.wallet = wallet
        }
    }                      
}


// MARK: - Send WalletInfo info
extension DetailViewController {
    
    @objc func shareWalletInfo(_ sender: Any) {
        
        UIAlertController(title: nil, 
                          message: nil, 
                          preferredStyle: .actionSheet)
            .addAction(title: NSLocalizedString("Print Payment Ticket", comment: ""), style: .default) { (alert) in
                self.fillPayments()
            } 
            .addAction(title: NSLocalizedString("Send Payment Link", comment: ""), style: .default, handler: { (alert) in
                self.sendLink()
            })
            .addAction(title: NSLocalizedString("Print Wallet Secret Papper", comment: ""), style: .default) { (alert) in
                self.printSecretPaper() 
            } 
            .addAction(title: "Cancel", style: .cancel) 
            .present(by: self)          
    }
}
