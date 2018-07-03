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

class PaymentController: NavigationController {    
    let contentController = PaymentControllerImp()     
    override func viewDidLoad() {
        super.viewDidLoad()        
        setViewControllers([contentController], animated: true)        
    }       
}


// MARK: - Print
extension PaymentControllerImp {
    @objc func closePayments(sender:Any){
        dismiss(animated: true) 
    }    
    
    @objc func printPayments(sender:Any){
        Printer.shared.printPDF(wallet: self.wallet, 
                                formater: { return HTMLTemplate.getAmount(wallet:$0, assets: self.currentAssets, amount: self.amount ) }
        ){ (controller, completed, error) in                                            
            if completed {
                self.dismiss(animated: true) 
            }
        } 
    }
    
    func printSecretPaper() {                            
        Printer.shared.printPDF(wallet: wallet, 
                                formater: { return HTMLTemplate.get(wallet:$0) }, 
                                complete: nil)                    
    }    
}

class PaymentControllerImp: Controller {   
    
    var wallet:Wallet?
    var currentAssets:String = "MILE" {
        didSet{
            assetText.text = currentAssets
        }
    }
    var amount:String = "0.0"
    
    lazy var amountText:UITextField = {
        let text = UITextField.decimalsField()
        text.addTarget(self, action: #selector(amounthandler(sender:)), for: UIControlEvents.editingChanged)
        text.addTarget(self, action: #selector(amounthandler(sender:)), for: UIControlEvents.editingDidEnd)
        return text
    }()
    
    lazy var assetText:UILabel = {
        let text = UILabel()
        text.isUserInteractionEnabled = false
        text.textAlignment = .left
        return text
    }()
    
    lazy var amountQr:UIImageView = UIImageView(image: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()                
        
        navigationItem.title = NSLocalizedString("Payment Ticket", comment: "")

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closePayments(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Print", comment: ""), style: .plain, target: self, action: #selector(self.printPayments(sender:)))

        view.addSubview(amountText)
        view.addSubview(assetText)        
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
        
        assetText.snp.makeConstraints { (make) in
            make.centerX.equalTo(amountText.snp.centerX)
            make.bottom.equalTo(amountText.snp.top).offset(-20)
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
        amountQr.image = wallet?.paymentQr(assets: currentAssets, amount: amount)
    }
    
}
