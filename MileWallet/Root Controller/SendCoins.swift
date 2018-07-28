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
    
    public var contact:Contact? {
        didSet{
            contactView.avatar = contact?.photo
            contactView.name = contact?.name
            contactView.publicKey = contact?.publicKey
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
                        color: UIColor.black.withAlphaComponent(0.1),
                        width: 1, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
      
        contentView.addSubview(amount)
        amount.snp.makeConstraints { (m) in
            m.top.equalTo(contactView.snp.bottom).offset(10)
            m.height.equalTo(60)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }
        amount.add(border: .bottom,
                        color: UIColor.black.withAlphaComponent(0.1),
                        width: 1, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        contentView.addSubview(coinsPicker)
        
        coinsPicker.showsSelectionIndicator = false
        coinsPicker.snp.makeConstraints { (m) in
            m.top.equalTo(amount.snp.bottom).offset(10)
            m.height.equalTo(60)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }
        coinsPicker.add(border: .bottom,
                   color: UIColor.black.withAlphaComponent(0.1),
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
       
        (navigationController as? NavigationController)?.titleColor = UIColor(hex: a.color)
    }
    
    @objc private func closePayments(sender:Any){
        dismiss(animated: true)
    }
    
    @objc private func doneHandler(_ sender: UIButton) {

    }
    
    lazy var contactView:ContactView = ContactView()
    lazy var amount:UITextField = UITextField.nameField(placeholder: NSLocalizedString("Amount", comment: ""))
    
    lazy var coinsPicker:UIPickerView = UIPickerView()
}

extension SendCoinsImp: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        pickerView.subviews.forEach({
            $0.isHidden = $0.frame.height < 1.0
        })
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SendCoinsImp.coins.count
    }
    
    // delegate method to return the value shown in the picker

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let coin:UILabel = UILabel()
        coin.textAlignment = .left
        coin.text = SendCoinsImp.coins[row].name
        return coin
    }

    
    static let coins = Asset.list
}
