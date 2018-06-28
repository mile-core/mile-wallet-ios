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

class PaymentController: Controller {   
    
    var wallet:Wallet?

    var currentAssets:String = "XDR"
    
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
    
    var amount:String = "0.0"
    
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
