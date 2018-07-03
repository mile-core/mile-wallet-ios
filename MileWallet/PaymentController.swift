//
//  PaymentController.swift
//  MileWallet
//
//  Created by denis svinarchuk on 14.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import SnapKit
import MileWalletKit

public class NavigationController: UINavigationController {
}

class PaymentController: NavigationController {
    
    let contentController = PaymentControllerImp() 
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        setViewControllers([contentController], animated: true)        
        let close = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closePayments(sender:)))
        let ok = UIBarButtonItem(title: NSLocalizedString("Print", comment: ""), style: .plain, target: self, action: #selector(self.printPayments(sender:)))
        topViewController?.navigationItem.title = NSLocalizedString("Payment Ticket", comment: "")
        topViewController?.navigationItem.leftBarButtonItem = close
        topViewController?.navigationItem.rightBarButtonItem = ok
    }
    
    @objc func closePayments(sender:Any){
        dismiss(animated: true) 
    }    
    
    @objc func printPayments(sender:Any){
        Printer.shared.printPDF(wallet: self.contentController.wallet, 
                                formater: { return HTMLTemplate.getAmount(wallet:$0, assets: self.contentController.currentAssets, amount: self.contentController.amount ) }
        ){ (controller, completed, error) in                                            
            if completed {
                self.dismiss(animated: true) 
            }
        } 
    }
    
    func printSecretPaper() {                            
        Printer.shared.printPDF(wallet:  contentController.wallet, 
                                formater: { return HTMLTemplate.get(wallet:$0) }, 
                                complete: nil)                    
    }    
}

class PaymentControllerImp: Controller {   
    
    var wallet:Wallet?
    var currentAssets:String = "XDR"
    var amount:String = "0.0"
    
    lazy var amountText:UITextField = {
        let text = UITextField()
        text.keyboardType = .decimalPad
        text.textAlignment = .center
        text.borderStyle = .bezel
        text.layer.borderWidth = 0.5
        text.addTarget(self, action: #selector(amounthandler(sender:)), for: UIControlEvents.editingChanged)
        text.addTarget(self, action: #selector(amounthandler(sender:)), for: UIControlEvents.editingDidEnd)
        return text
    }()
    
    lazy var amountQr:UIImageView = UIImageView(image: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()                
        
        view.addSubview(amountText)
        view.addSubview(amountQr)        
        
        amountQr.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(amountQr.snp.width)
            make.centerY.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        amountText.snp.makeConstraints { (make) in
            make.centerX.equalTo(amountQr.snp.centerX)
            make.bottom.equalTo(amountQr.snp.top).offset(-20)
            make.size.equalTo(CGSize(width: 150, height: 44))
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tap)
    }  
    
    @objc func tapHandler(gesture:UITapGestureRecognizer) {
        amountText.resignFirstResponder()
    }
    
    @objc func amounthandler(sender:UITextField){
        amount = "\((amountText.text ?? "").floatValue)"
        amountQr.image = wallet?.amountQRImage(assets: currentAssets, amount: amount)
    }
    
}
