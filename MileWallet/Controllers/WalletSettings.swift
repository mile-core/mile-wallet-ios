//
//  NewWalletController.swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit
import MileCsaLight
import ObjectMapper
import QRCodeReader

class WalletSettings: Controller, UITextFieldDelegate {
    
    public var isEdited:Bool = false
    public var wallet:WalletContainer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("New wallet", comment: "")
        
        contentView.backgroundColor = Config.Colors.background
        contentView.addSubview(qrReaderButton)
        contentView.addSubview(nameOrPk)
        contentView.addSubview(line)
        contentView.addSubview(colorLabel)
        contentView.addSubview(pickerView)
        contentView.addSubview(archiveButton)

        nameOrPk.delegate = self
        
        publicKeyConstraint()
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(nameOrPk.snp.bottomMargin).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }
        
        colorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    
        pickerView.snp.makeConstraints { (m) in
            m.top.equalTo(colorLabel.snp.bottom).offset(0)
            m.left.equalToSuperview().offset(0)
            m.right.equalToSuperview().offset(0)
            m.height.equalTo(80)
        }
        
        archiveButton.snp.remakeConstraints { (m) in
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            m.left.right.equalTo(contentView).inset(60)
            m.height.equalTo(60)
        }
        
        pickerView.cellSpacing = 20
        
        if let index = Config.Colors.palette.index(where: { (c) -> Bool in
            if c === Config.Colors.defaultColor {
                return true
            }
            return false
        }) {
            pickerView.selectCellAtIndex(index)
        }
    }
    
    private func publicKeyConstraint(){
        
        nameOrPk.snp.remakeConstraints { (make) in
            make.top.equalTo(contentView.snp.topMargin).offset(10)
            make.left.equalToSuperview().offset(20)
            if isEdited {
                make.right.equalTo(contentView.snp.right).offset(-20)
            }
            else {
                make.right.equalTo(qrReaderButton.snp.left).offset(-5)
            }
            make.height.equalTo(60)
        }

        qrReaderButton.snp.remakeConstraints { (make) in
            make.top.equalTo(contentView.snp.topMargin).offset(10)
            make.centerX.equalTo(contentView.snp.right).offset(-30)
            make.height.equalTo(nameOrPk.snp.height)
            make.width.equalTo(qrReaderButton.snp.height)
        }

        if isEdited {
            qrReaderButton.alpha = 0
            qrReaderButton.isUserInteractionEnabled = false
        }
        else {
            qrReaderButton.alpha = 1
            qrReaderButton.isUserInteractionEnabled = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(self.closeHandler(sender:)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneHandler(_:)))
        
        self.navigationController?.navigationBar.prefersLargeTitles = true

        publicKeyConstraint()
        
        super.viewWillAppear(animated)
        if let wallet = self.wallet {
            title = NSLocalizedString("Settings", comment: "")
            nameOrPk.text = wallet.wallet?.name
            archiveButton.isUserInteractionEnabled = true
            archiveButton.isHidden = false
        }
        else {
            archiveButton.isUserInteractionEnabled = false
            archiveButton.isHidden = true
        }
        
        guard let a = wallet?.attributes else {
            return
        }
        
        (navigationController as? NavigationController)?.titleColor = UIColor(hex: a.color)
        
        if a.isActive {
            nameOrPk.placeholder = NSLocalizedString("Wallet Name", comment: "")
            archiveButton.setTitle(NSLocalizedString("Archive wallet", comment: ""), for: .normal)
        }
        else {
            nameOrPk.placeholder = NSLocalizedString("Name or Private Key", comment: "")
            archiveButton.setTitle(NSLocalizedString("Restore wallet", comment: ""), for: .normal)
        }
        
        if let index = Config.Colors.palette.index(where: { (c) -> Bool in
            return c.hex == a.color
        }) {
            pickerView.selectCellAtIndex(index)
        }
    }    
    
    @objc private func closeHandler(sender:Any){
        dismiss(animated: true)
    }
    
    @objc private func doneHandler(_ sender: UIButton) {
        if let wallet = self.wallet?.wallet, let a = self.wallet?.attributes {
            self.updateWallet(wallet: wallet, attributes: a)
        }
        else {
            addWallet()
        }
    }
    
    private lazy var pickerView: ColorPicker = {
        let v = ColorPicker(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 60))
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    private let line:UIView = {
        let l = UIView()
        l.backgroundColor = Config.Colors.separator
        return l
    }()
    
    private let colorLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.text = NSLocalizedString("Wallet color", comment: "")
        l.textColor = Config.Colors.caption
        l.font = Config.Fonts.caption
        return l
    }()
    
    private let nameOrPk: UITextField = {
        let t = UITextField.nameField(placeholder: NSLocalizedString("Name or Private Key", comment: ""))
        return t
    }()
    
    private lazy var qrReaderButton: UIButton = {
        let b = Button(image: UIImage(named: "button-read"), action: { (sender) in

            self.currentPrivateKeyQrCount = 0
            self.currentPrivateKeyQr = nil
            self.currentNameQr = nil

            self.qrCodeReader.open { (reader, result) in
                self.reader(reader, didScanResult: result)
            }
        })
        return b
    }()
    
    fileprivate var currentColor = Config.Colors.defaultColor
    fileprivate var currentWallet:Wallet?    
    
    fileprivate lazy var archiveButton:UIButton = {
        let copy = UIButton(type: .custom)
        copy.setTitle(NSLocalizedString("Archive wallet", comment: ""), for: .normal)
        copy.setTitleColor(UIColor.white, for: .normal)
        copy.titleLabel?.font = Config.Fonts.caption
        copy.backgroundColor = Config.Colors.redButton
        copy.layer.cornerRadius = Config.buttonRadius
        copy.addTarget(self, action: #selector(self.archiveButtonHandler(sender:)), for: .touchUpInside)
        return copy
    }()
    
    @objc func archiveButtonHandler(sender:UIButton){
        guard let w = wallet?.wallet, let a = wallet?.attributes else {
            return
        }
        if a.isActive {
            UIAlertController(title: NSLocalizedString("Archive wallet \(w.name!)", comment: ""),
                              message: nil,
                              preferredStyle: .actionSheet)
                .addAction(title: NSLocalizedString("Archive", comment: ""), style: .default) { _ in
                    self.updateWallet(wallet: w, attributes: a, isActive: !a.isActive)
                }
                .addAction(title: NSLocalizedString("Close", comment: ""), style: .cancel)
                .present(by: self)
        }
        else {
             self.updateWallet(wallet: w, attributes: a, isActive: !a.isActive)
        }
    }
    
    fileprivate lazy var attentionCover:UIView = {
        let v = UIView()
        let image = UIImageView(image: Config.Images.basePattern)
        image.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        image.frame = v.bounds
        image.contentMode = .scaleAspectFill
        v.addSubview(image)
        v.backgroundColor = self.currentColor

        let printerIcon = UIImageView(image: Config.Images.printerIcon)
        v.addSubview(printerIcon)
        printerIcon.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.top.equalToSuperview().offset(140)
            m.size.equalTo(Config.Images.printerIcon.size)
        })

        let header = UILabel()
        header.textAlignment = .center
        header.text = NSLocalizedString("Important!", comment: "")
        header.textColor = Config.Colors.header
        header.font = Config.Fonts.header
        
        v.addSubview(header)
        header.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            
            m.top.equalTo(printerIcon.snp.bottom).offset(40)
            m.width.equalToSuperview()
        })

        let back = UIButton(type: .custom)
        back.setTitle(NSLocalizedString("Back to main screen", comment: ""), for: UIControl.State.normal)
        back.setTitleColor(Config.Colors.back, for: .normal)
        back.titleLabel?.font = Config.Fonts.caption
        back.backgroundColor = UIColor.white
        back.layer.cornerRadius = Config.buttonRadius
        back.addTarget(self, action: #selector(backMainHandler(sender:)), for: UIControl.Event.touchUpInside)
        v.addSubview(back)
        back.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalTo(v.safeAreaLayoutGuide.snp.bottom).offset(-15)
            m.width.equalToSuperview().offset(-40)
            m.height.equalTo(60)
        })

        let text = UITextView()
        text.backgroundColor = UIColor.clear
        text.isUserInteractionEnabled = false
        text.textAlignment = .center
        text.textContainer.lineBreakMode = .byWordWrapping
        text.textContainer.maximumNumberOfLines = 5
        text.isSelectable = true
        text.isScrollEnabled = false
        text.layer.borderWidth = 0.0
        text.font = Config.Fonts.caption
        text.clearsOnInsertion = true
        text.textColor = UIColor.white
        text.resignFirstResponder()

        text.text = NSLocalizedString("You should SAVE your public and private key or you will not have a chance to restore your wallet!", comment: "")

        let textContainer = UIView()
        textContainer.backgroundColor = Config.Colors.attentionText
        textContainer.layer.cornerRadius = Config.buttonRadius
        textContainer.clipsToBounds = true

        v.addSubview(textContainer)

        textContainer.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalTo(back.snp.top).offset(-18)
            m.width.equalToSuperview().offset(-40)
            m.height.equalTo(211)
        })

        textContainer.addSubview(text)

        text.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview().offset(-60)
            m.width.equalToSuperview().offset(-40)
            m.top.equalToSuperview().offset(24)
        })

        let line = UIView()
        line.backgroundColor = Config.Colors.line
        textContainer.addSubview(line)

        line.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview().offset(-60)
            m.width.equalToSuperview()
            m.height.equalTo(1)
        })

        let print = UIButton(type: .custom)
        print.setTitle(NSLocalizedString("Print Wallet Secret Paper", comment: ""), for: UIControl.State.normal)
        print.setTitleColor(UIColor.white, for: .normal)
        print.titleLabel?.font = Config.Fonts.caption
        print.backgroundColor = UIColor.clear
        print.addTarget(self, action: #selector(printHandler(sender:)), for: UIControl.Event.touchUpInside)
        textContainer.addSubview(print)

        print.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview()
            m.width.equalToSuperview()
            m.top.equalTo(line.snp.bottom)
        })

        return v
    }()
    
    fileprivate lazy var printControllerBg:UIImageView = {
        let v = UIImageView(image: Config.Images.basePattern)
        v.alpha = 0
        return v
    }()
    
    var currentPrivateKeyQr:String?
    var currentNameQr:String?
    var currentPrivateKeyQrCount:Int = 0
}

extension WalletSettings {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        
        if result.value.hasPrefix(Config.Shared.Wallet.privateKey){
            currentPrivateKeyQrCount += 1
            currentPrivateKeyQr = result.value.replacingOccurrences(of: Config.Shared.Wallet.privateKey, with: "")
        }
        
        if result.value.hasPrefix(Config.Shared.Wallet.name){
            currentNameQr = result.value.replacingOccurrences(of: Config.Shared.Wallet.name, with: "")
        }
    
        if currentPrivateKeyQr != nil,
            let name = currentNameQr {

            reader.stopScanning()
           
            nameOrPk.text = name
            reader.dismiss(animated: true)
        }
        else if  currentPrivateKeyQrCount > 3 {

            reader.stopScanning()

            nameOrPk.text =  Date.currentTimeString
            reader.dismiss(animated: true)
            
            if currentPrivateKeyQr == nil {
                UIAlertController(title: nil,
                                  message: NSLocalizedString("MILE QR Code is not valid", comment: ""),
                                  preferredStyle: .actionSheet)
                    .addAction(title: NSLocalizedString("Close", comment: ""), style: .cancel)
                    .present(by: self)
            }
        }
    }
}

extension WalletSettings: UIPrintInteractionControllerDelegate {
    
    func printInteractionControllerParentViewController(_ printInteractionController: UIPrintInteractionController) -> UIViewController? {
        return self.navigationController?.topViewController
    }
    
    func printInteractionControllerWillPresentPrinterOptions(_ printInteractionController: UIPrintInteractionController) {
        UIApplication.shared.keyWindow?.addSubview(printControllerBg)
      
        printControllerBg.snp.makeConstraints { (m) in
            m.edges.equalToSuperview().inset(UIEdgeInsets(top: -200, left: 0, bottom: 0, right: 0))
        }
        printControllerBg.backgroundColor = currentColor
        UIView.animate(withDuration: Config.animationDuration) {
            self.printControllerBg.alpha = 1
        }
    }
    
    func printInteractionControllerDidDismissPrinterOptions(_ printInteractionController: UIPrintInteractionController) {
        UIView.animate(withDuration: Config.animationDuration, animations: {
            self.printControllerBg.alpha = 0
        }) { (flag) in
            self.printControllerBg.removeFromSuperview()
        }
    }
}

extension WalletSettings {
    
    @objc fileprivate func backMainHandler(sender:UIButton){
        coverDown()
        self.dismiss(animated: true)
    }
    
    
    @objc fileprivate func printHandler(sender:UIButton){
        loaderStart()
        Printer.shared.printController.delegate = self
        Printer.shared.printPDF(wallet: currentWallet,
                                formater: { return HTMLTemplate.secret(wallet:$0) },
                                complete: { _,complete,_ in
                                    self.loaderStop()
        })
    }
    
    private func coverDown() {
        UIView.animate(withDuration: Config.animationDuration, animations: {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.attentionCover.alpha = 0
        }, completion: { (flag) in
            self.attentionCover.removeFromSuperview()
        })
    }
    
    private func coverUp()  {
        nameOrPk.resignFirstResponder()
        attentionCover.alpha = 0
        attentionCover.backgroundColor = self.currentColor
        attentionCover.frame = UIScreen.main.bounds
        UIApplication.shared.keyWindow?.addSubview(attentionCover)
        attentionCover.snp.makeConstraints { (m) in
            m.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
       
        UIView.animate(withDuration: Config.animationDuration,
                       animations: {
                        self.attentionCover.alpha = 1
        }) { (flag) in
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.attentionCover.removeFromSuperview()
            self.view.addSubview(self.attentionCover)
            self.attentionCover.snp.makeConstraints { (m) in
                m.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
        }
    }
    
    fileprivate func updateWallet(wallet:Wallet, attributes:WalletAttributes?, isActive:Bool = true){
        
        func close() {
            self.dismiss(animated: true, completion: nil)
        }
        
        do {
            guard let oldName = wallet.name else { return }
            
            self.currentWallet = wallet
            
            if self.wallet != nil, wallet.name != self.nameOrPk.text {

                self.currentWallet = Wallet(name: self.nameOrPk.text!,
                            publicKey: wallet.publicKey!,
                            privateKey: wallet.privateKey!,
                            secretPhrase: wallet.secretPhrase)

            }

            guard let wallet = self.currentWallet else {
                return
            }

            guard let key = wallet.publicKey else { return }
            guard let name = wallet.name else { return }

            if oldName != name {
                if !checkWallet(name: name) {
                    return
                }
            }
            
            let walletAttr = WalletAttributes(
                publicKey: key,
                color: self.currentColor.hex,
                isActive: isActive,
                sortOrder:attributes?.sortOrder ?? time(nil))
            
            try WalletStore.shared.save(wallet: WalletContainer(wallet: wallet, attributes: walletAttr))
            
            self.loaderStop()

            if self.wallet == nil {
                self.coverUp()
            }
            else {
                close()
            }
            
        }
        catch let error {
            
            UIAlertController(title: nil,
                              message:  error.description,
                              preferredStyle: .alert)
                .addAction(title: WalletSettings.closeString, style: .cancel, handler: { (action) in
                    close()
                })
                .present(by: self)
        }
    }
    
    fileprivate static let closeString = NSLocalizedString("Close", comment: "")

    private func checkWallet(name:String) -> Bool {
        
        let checkWallet = WalletStore.shared.find(name: name)
        
        if let wallet = checkWallet, let a = wallet.attributes, a.isActive {
            UIAlertController(title: NSLocalizedString("Wallet Error", comment: ""),
                              message:  NSLocalizedString("Wallet with the same name already exists", comment: ""),
                              preferredStyle: .alert)
                .addAction(title: WalletSettings.closeString, style: .cancel)
                .present(by: self)
            return false
        }
        
        return true
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
    
    fileprivate func addWallet()  {
        
        func close() {
            self.loaderStop()
            self.dismiss(animated: true, completion: nil)
        }
        
        guard let name = nameOrPk.text, !name.isEmpty  else {

            UIAlertController(title: NSLocalizedString("Wallet error", comment: ""),
                              message: NSLocalizedString("Wallet name is empty", comment: ""),
                              preferredStyle: .actionSheet)
                .addAction(title: WalletSettings.closeString, style: .cancel)
                .present(by: self)
            return
        }
                
        if !checkWallet(name: name) {
            return
        }
        
        loaderStart()

        do {
            let n_name = currentNameQr ?? Date.currentTimeString
            let n_pk   = currentPrivateKeyQr ?? name
            
            Swift.print("..... >>>> \(n_name), \(n_pk)")
            
            if MileCsaKeys.validatePublic(n_pk) {
                UIAlertController(title: NSLocalizedString("Wallet error", comment: ""),
                                  message: NSLocalizedString("Wallet name or private key looks like a public", comment: ""),
                                  preferredStyle: .actionSheet)
                    .addAction(title: WalletSettings.closeString, style: .cancel){ action in
                        close()
                    }
                    .present(by: self)
                
                return
            }
            
            if MileCsaKeys.validatePublic(name) {
                UIAlertController(title: NSLocalizedString("Wallet error", comment: ""),
                                  message: NSLocalizedString("Wallet name looks like a public", comment: ""),
                                  preferredStyle: .actionSheet)
                    .addAction(title: WalletSettings.closeString, style: .cancel){ action in
                        close()
                    }
                    .present(by: self)
                
                return
            }
            
            let fromPk =
                try Wallet(name: n_name, privateKey: n_pk)
            
            self.loaderStop()

            if WalletStore.shared.wallet(by: fromPk.publicKey!) != nil {
               
                UIAlertController(title: NSLocalizedString("Wallet error", comment: ""),
                                  message: NSLocalizedString("Wallet with the same public key already exists: ", comment: "") + fromPk.publicKey!,
                                  preferredStyle: .actionSheet)
                    .addAction(title: WalletSettings.closeString, style: .cancel){ action in
                        close()
                    }
                    .present(by: self)
                
                return
            }
            
            UIAlertController(title: NSLocalizedString("Success!", comment: ""),
                              message: NSLocalizedString("Private Key is valid. Wallet address: ", comment: "") + fromPk.publicKey!,
                              preferredStyle: .actionSheet)
                .addAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel){ action in
                    close()
                }
                .addAction(title: NSLocalizedString("Accept", comment: ""), style: .default){ action in
                    self.updateWallet(wallet: fromPk, attributes: nil)
                }
                .present(by: self)
        }
        catch {
            
            Wallet.create(name: name, secretPhrase: nil, error: { error in
               
                UIAlertController(title: NSLocalizedString("Wallet Error", comment: ""),
                                  message:  error?.description,
                                  preferredStyle: .alert)
                    .addAction(title: WalletSettings.closeString, style: .cancel) { action in
                        close()
                    }
                    .present(by: self)
                
            }) { (wallet) in
                
                self.updateWallet(wallet: wallet, attributes: nil)
                
            }
        }
    }
}

extension WalletSettings: ColorPickerDataSource {
    func colorPickerColors() -> [UIColor] {
        return Config.Colors.palette
    }
}

extension WalletSettings: ColorPickerDelegate {
    
    func colorPicker(_ colorPickerView: ColorPicker, didSelectCell cell: ColorPickerCell) {
        cell.layer.contents = Config.Images.colorPickerOn.cgImage
        cell.layer.contentsScale = 4
        cell.layer.contentsGravity = CALayerContentsGravity.center
        cell.layer.isGeometryFlipped = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.16
        cell.layer.shadowOffset = CGSize(width: 0, height: -3)
        cell.layer.shadowRadius = 3
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.masksToBounds = false
    }
    
    func colorPicker(_ colorPickerView: ColorPicker, didSelectIndex at: Int, color: UIColor) {
        (navigationController as? NavigationController)?.titleColor = color
        currentColor = color
    }
    
    func sizeForCellAtIndex(_ colorPickerView: ColorPicker, index at: Int) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}
