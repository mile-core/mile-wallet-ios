//
//  SendCoins.swift
//  MileWallet
//
//  Created by denn on 29.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

class CoinsOperation: Controller {
    
    enum Style {
        case contact
        case publicKey
        case print
        case invoiceLink
    }
    
    public var style:CoinsOperation.Style = .contact {
        didSet{
            headerViewLayout()
        }
    }
    
    public var wallet:WalletContainer?
    
    public var invoice:WalletUniversalLink.Invoice? {
        didSet {
            
            currentAsset = Asset(name: invoice?.assets ?? Asset.mile.name) ?? currentAsset

            let idx =  Asset.list.index(where: { (i) -> Bool in
                return i.name == currentAsset.name
            })
            
            contactView.isEdited = false
            contactView.publicKey = invoice?.publicKey
            updateAvatar()
            
            if let pk = invoice?.publicKey {
                let contact = Contact.find(pk, for: "publicKey").first
                contactView.avatar = contact?.photo
            }
            
            if let t = invoice?.amount?.floatValue {
                amountTextFeild.text = currentAsset.stringValue(t)
            }
            
            currentAssetIndex = idx ?? 0
            coinsPicker.selectRow(currentAssetIndex, inComponent: 0, animated: false)
            
            amountTextFeild.isUserInteractionEnabled = false
            coinsPicker.isUserInteractionEnabled = false
        }
    }

    private lazy var successScreen = SuccessController()
    
    private var currentAsset:Asset = .mile
    private var currentAssetIndex = 0
    
    private func updateAvatar() {
        if let pk = contactView.publicKey {
            let contact = Contact.find(pk, for: "publicKey").first
            contactView.avatar = contact?.photo
        }
    }
    
    public var newPublicKey:String? {
        didSet{
            contactView.isEdited = false
            contactView.publicKey = newPublicKey
            updateAvatar()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        amountTextFeild.isUserInteractionEnabled = true
        coinsPicker.isUserInteractionEnabled = true
        amountTextFeild.text = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Send Coins", comment: "")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(self.closeHandler(sender:)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(doneHandler(_:)))

        let bg = UIView()
        bg.backgroundColor = UIColor.white
        contentView.addSubview(bg)
        bg.snp.remakeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        
        contentView.addSubview(headerView)
        headerView.addSubview(contactView)
        headerView.addSubview(qrCodeHeader)

        headerView.snp.makeConstraints { (m) in
            m.height.equalTo(80)
            m.right.left.equalTo(contentView)
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        
        contactView.snp.remakeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        qrCodeHeader.snp.remakeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        qrCodeHeader.addSubview(self.qrCodePreview)
        qrCodePreview.snp.makeConstraints({ (m) in
            m.left.equalTo(qrCodeHeader).offset(20)
            m.top.equalTo(qrCodeHeader).offset(5)
            m.bottom.equalTo(qrCodeHeader).offset(0)
            m.width.equalTo(qrCodePreview.snp.height)
        })
        
        contentView.addSubview(amountTextFeild)
        
        amountTextFeild.snp.makeConstraints { (m) in
            m.top.equalTo(headerView.snp.bottom).offset(10)
            m.height.equalTo(60)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }
        amountTextFeild.add(border: .bottom,
                        color: Config.Colors.bottomLine,
                        width: 1, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        contentView.addSubview(coinsPicker)
        
        coinsPicker.showsSelectionIndicator = false
        coinsPicker.snp.makeConstraints { (m) in
            m.top.equalTo(amountTextFeild.snp.bottom).offset(-5)
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
    
    fileprivate func headerViewLayout(){
        var title:String
        
        headerView.remove(border: .bottom)
        
        switch style {
            
        case .contact, .publicKey:
            title = NSLocalizedString("Send Coins", comment: "")

            contactView.alpha = 1
            qrCodeHeader.alpha = 0
            headerView.add(border: .bottom,
                           color: Config.Colors.bottomLine,
                           width: 1, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            title = NSLocalizedString("Done", comment: "")
            
        case .print, .invoiceLink:
            contactView.alpha = 0
            qrCodeHeader.alpha = 1
            qrCodeUpdate()
            title = NSLocalizedString("Next", comment: "")
            
            self.title = style == .print ?
                NSLocalizedString("Print Invoice", comment: "") :
                NSLocalizedString("Link Invoice", comment: "")
        }
        
        navigationItem.rightBarButtonItem?.title = title
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerViewLayout()

        coinsPicker.selectRow(currentAssetIndex, inComponent: 0, animated: false)

        guard let a = wallet?.attributes else {
            return
        }
        
        amountTextFeild.placeholder = amountTextFeild.text
        (navigationController as? NavigationController)?.titleColor = UIColor(hex: a.color)
    }
    
    @objc private func closeHandler(sender:Any){
        dismiss(animated: true)
    }
    
    private func acceptedSend(from:Wallet, to: String, asset: Asset, amount:Float) {

        let toWallet = Wallet(name: to, publicKey: to, privateKey: "", secretPhrase: nil)
                
        loaderStart()

        Transfer.send(
            asset:  asset.name,
            amount: amount,
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
            self.successScreen.publicKey = toWallet.publicKey
            self.successScreen.view.backgroundColor =
                UIColor(hex: self.wallet?.attributes?.color ?? Config.Colors.defaultColor.hex)
            self.successScreen.amount = asset.stringValue(amount)
            self.successScreen.asset = asset
            self.present(self.successScreen, animated: true)
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
        
            let code = Asset(name: asset.name)!.code 
            
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
            mess += " \(amount) \(asset.name) "
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
    
    private func send(amount asked: Float) {
        
        guard let toKey = self.contact?.publicKey ?? contactView.publicKey else {
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
                .addAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
                .present(by: self)
        }) { (balance) in
            let asset = Asset.list[self.coinsPicker.selectedRow(inComponent: 0)]
            self.sendCoin(from: w, to: toKey, asset: asset, amount: asked, balance: balance)
        }
    }
    
    @objc private func doneHandler(_ sender: UIButton) {
        
        view.endEditing(true)
        let asset = Asset.list[self.coinsPicker.selectedRow(inComponent: 0)]

        func amounNotEnough(){
            UIAlertController(title: nil,
                              message: NSLocalizedString("Amount is not valid", comment: ""),
                              preferredStyle: .actionSheet)
                .addAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
                .present(by: self)
        }
        
        guard let asked = amountTextFeild.text?.floatValue, asked > 0.0 else {
            amounNotEnough()
            return
        }
        
        switch style {
        case .contact, .publicKey:
            
            send(amount: asked)
            
        case .print:
            
            let asked = amountTextFeild.text?.floatValue ?? 0.0
            
            loaderStart()
            Printer.shared.printController.delegate = self
            
            Printer.shared.printPDF(wallet: wallet?.wallet,
                                    formater: {
                                        //if asked > 0.0 {
                                            return HTMLTemplate.invoice(wallet: $0,
                                                                        assets: asset.name,
                                                                        amount: asset.stringValue(asked))
//
//  TODO: PRINT address
//
//                                        }
//                                        else {
//                                            return HTMLTemplate.contact(wallet: $0)
//                                        }
                                        
            },
                                    complete: { _,complete,_ in
                                        self.loaderStop()
            })
            
        case .invoiceLink:
            
            guard let asked = amountTextFeild.text?.floatValue, asked > 0.0 else {
                amounNotEnough()
                return
            }
            
            guard let url = wallet?.wallet?.paymentLink(assets: asset.name, amount: asset.stringValue(asked)) else { return }
            
            let activity = UIActivityViewController(
                activityItems: ["Please send your coins to the address", url],
                applicationActivities:nil)
            
            if let popoverController = activity.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            present(activity, animated: true)
        }
    }
    
    fileprivate lazy var headerView:UIView = UIView()
    
    fileprivate lazy var contactView:ContactView = ContactView()
    fileprivate lazy var qrCodePreview:UIImageView = {
        let image = UIImageView()
        image.image = "0.0".qrCodeImage
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = Config.buttonRadius * 2
        image.layer.masksToBounds = true
        image.clipsToBounds = true
        return image
    }()
    
    fileprivate lazy var qrCodeHeader:UIView = {
        let u = UIView()
        return u
    }()
    
    fileprivate lazy var amountTextFeild:UITextField = {
       let a = UITextField.decimalsField()
        a.delegate = self
        a.addTarget(self, action: #selector(amountChainging(_:)), for: UIControl.Event.allEditingEvents)
        return a
    }()
    
    fileprivate lazy var coinsPicker:UIPickerView = {
        return UIPickerView()
    }()
}

extension CoinsOperation: UIPrintInteractionControllerDelegate {
    
    func printInteractionControllerParentViewController(_ printInteractionController: UIPrintInteractionController) -> UIViewController? {
        return self.navigationController
    }
    
    func printInteractionControllerWillPresentPrinterOptions(_ printInteractionController: UIPrintInteractionController) {
        self.navigationController?.navigationBar.backgroundColor =  UIColor.clear
    }
}

extension CoinsOperation: UITextFieldDelegate {

    @objc fileprivate func amountChainging(_ sender:UITextField) {

        let asset = Asset.list[self.coinsPicker.selectedRow(inComponent: 0)]
        if let text = sender.text {
            let t = text.split {"." == $0 || "," == $0}
            if t.count == 2 {
                let n = (String(t[0])).count
                let d = (String(t[1])).count
                if d > asset.precision {
                    self.amountTextFeild.text = text[0..<asset.precision+n+1] //asset.stringValue(v)
                }
            }
        }
        
        qrCodeUpdate()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func qrCodeUpdate()  {
        
        if let t = amountTextFeild.text?.floatValue, t > 0.0 {
            qrCodePreview.image = "\(t)".qrCodeImage
            UIView.animate(withDuration: Config.animationDuration) {
                self.qrCodePreview.alpha = 1
            }
        }
        else {
            UIView.animate(withDuration: Config.animationDuration) {
                self.qrCodePreview.alpha = 0.3
            }
        }
    }

    private func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if amountTextFeild.text != nil {
            amountTextFeild.placeholder = nil
        }
    }
}

// MARK: - datasource
extension CoinsOperation: UIPickerViewDataSource {
    static let coins = Asset.list

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        pickerView.subviews.forEach({
            $0.isHidden = $0.frame.height < 1.0
        })
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CoinsOperation.coins.count
    }
}

extension CoinsOperation: UIPickerViewDelegate{
    // delegate method to return the value shown in the picker
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let coin:UILabel = UILabel()
        coin.textAlignment = .left
        coin.text = CoinsOperation.coins[row].name
        return coin
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        amountChainging(amountTextFeild)
    }
}
