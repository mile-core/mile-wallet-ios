//
//  SendCoins.swift
//  MileWallet
//
//  Created by denn on 29.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

class SendCoins: NavigationController {
    
    public var wallet:WalletContainer? {
        set{
            contentController.wallet = newValue
        }
        get {
            return contentController.wallet
        }
    }
    
    public var newPublicKey:String?{
        get {
            return contentController.newPublicKey
        }
        set {
            contentController.newPublicKey = newValue
        }
    }
    
    public var contact:Contact? {
        set{
            contentController.contact = newValue
        }
        get {
            return contentController.contact
        }
    }
    
    let contentController = SendCoinsImp()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Config.Colors.background
        setViewControllers([contentController], animated: true)
    }
}

class SendCoinsImp: Controller {
    
    public var wallet:WalletContainer?
    
    fileprivate var newPublicKey:String? {
        didSet{
            contactView.isEdited = false
            contactView.publicKey = newPublicKey
        }
    }
    
    public var contact:Contact? {
        didSet{
            if contact == nil {
                contactView.isEdited = true
            }
            else {
                contactView.isEdited = false
                contactView.avatar = contact?.photo
                contactView.name = contact?.name
                contactView.publicKey = contact?.publicKey
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Send Coins", comment: "")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(self.closePayments(sender:)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain,
                                                            target: self,
                                                            action: #selector(doneHandler(_:)))
        
        contentView.addSubview(contactView)
        contactView.snp.makeConstraints { (m) in
            m.height.equalTo(80)
            m.right.left.equalTo(contentView)
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        
        contactView.add(border: .bottom,
                        color: Config.Colors.bottomLine,
                        width: 1, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
      
        contentView.addSubview(amount)
        amount.snp.makeConstraints { (m) in
            m.top.equalTo(contactView.snp.bottom).offset(10)
            m.height.equalTo(60)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }
        amount.add(border: .bottom,
                        color: Config.Colors.bottomLine,
                        width: 1, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        contentView.addSubview(coinsPicker)
        
        coinsPicker.showsSelectionIndicator = false
        coinsPicker.snp.makeConstraints { (m) in
            m.top.equalTo(amount.snp.bottom).offset(-5)
            m.height.equalTo(95)
            m.left.equalTo(contentView.snp.right).offset(-60)
            m.right.equalToSuperview().offset(-20)
        }
        coinsPicker.add(border: .bottom,
                   color: Config.Colors.bottomLine,
                   width: 1, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

        coinsPicker.dataSource = self
        coinsPicker.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        guard let a = wallet?.attributes else {
            return
        }
        
        amount.placeholder = amount.text
        amount.text = nil
        (navigationController as? NavigationController)?.titleColor = UIColor(hex: a.color)
    }
    
    @objc private func closePayments(sender:Any){
        dismiss(animated: true)
    }
    
    private func acceptedSend(from:Wallet, to: String, asset: Asset, amount:Float) {

        let toWallet = Wallet(name: to, publicKey: to, privateKey: "", secretPhrase: nil)
        
        loaderStart()

        Transfer.send(
            asset:  asset.name,
            amount: "\(amount)",
            from:   from,
            to:     toWallet,
            error: { error in
                
                UIAlertController(title: NSLocalizedString("Transfer error", comment: ""),
                                  message:  error?.description,
                                  preferredStyle: .alert)
                    .addAction(title: "Close", style: .cancel)
                    .present(by: self)
                
                self.loaderStop()
                
        }) { (transfer) in
            self.loaderStop()
            self.dismiss(animated: true)
        }
    }
    
    private func sendCoin(from:Wallet, to: String, asset: Asset, amount:Float, balance:Balance) {
        Chain.update(error: { (error) in
            
            self.loaderStop()
            
            UIAlertController(title: nil,
                              message: error?.description,
                              preferredStyle: .actionSheet)
                .addAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
                .present(by: self)
            
            
        }) { (chain) in
        
            let code = chain.assetCode(of: asset.name)!
            
            let b = balance.amount(code)
                        
            self.loaderStop()

            guard let total = b, amount<=total else {
                
                let v = asset.stringValue(b ?? 0.0)
                var mess = NSLocalizedString("Your total \(asset.name) amount is ", comment:"")
                mess += v
                mess += NSLocalizedString(" that is less then ", comment: "") + asset.stringValue(amount)
                
                UIAlertController(title: nil,
                                  message: mess,
                                  preferredStyle: .actionSheet)
                    .addAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
                    .present(by: self)
                return
            }
            
            var mess = NSLocalizedString("Accept sending ", comment: "")
            mess += " \(amount) "
            mess += NSLocalizedString("coins to: ", comment: "") + (self.contact?.name ?? to)
            UIAlertController(title: NSLocalizedString("Sending coins...", comment: ""),
                              message: mess,
                              preferredStyle: .actionSheet)
                .addAction(title: "Accept", style: .default, handler: { (action) in
                    self.acceptedSend(from: from, to: to, asset: asset, amount: amount)
                })
                .addAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
                .present(by: self)
        }
        
    }
    
    @objc private func doneHandler(_ sender: UIButton) {
        
        view.endEditing(true)

        guard let toKey = self.contact?.publicKey ?? contactView.publicKey else {
            return
        }

        guard let asked = amount.text?.floatValue,
            asked > 0.0 else {
            
            UIAlertController(title: nil,
                              message: NSLocalizedString("Amount is not valid", comment: ""),
                              preferredStyle: .actionSheet)
                .addAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
                .present(by: self)
            
            return
        }
        
        guard let w = wallet?.wallet else {
           return
        }
        
        
        loaderStart()
        
        Balance.update(wallet: w, error: { (error) in
            UIAlertController(title: nil,
                              message: error?.description,
                              preferredStyle: .actionSheet)
                .present(by: self)
        }) { (balance) in
            let asset = Asset.list[self.coinsPicker.selectedRow(inComponent: 0)]
            self.sendCoin(from: w, to: toKey, asset: asset, amount: asked, balance: balance)
        }
    }
    
    lazy var contactView:ContactView = ContactView()
    lazy var amount:UITextField = {
       let a = UITextField.decimalsField()
        a.delegate = self
        return a
    }()
    
    lazy var coinsPicker:UIPickerView = UIPickerView()
}


extension SendCoinsImp: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if amount.text != nil {
            amount.placeholder = nil
        }
    }
}

// MARK: - datasource
extension SendCoinsImp: UIPickerViewDataSource {
    static let coins = Asset.list

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        pickerView.subviews.forEach({
            $0.isHidden = $0.frame.height < 1.0
        })
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SendCoinsImp.coins.count
    }
}

extension SendCoinsImp: UIPickerViewDelegate{
    // delegate method to return the value shown in the picker
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let coin:UILabel = UILabel()
        coin.textAlignment = .left
        coin.text = SendCoinsImp.coins[row].name
        return coin
    }
}
