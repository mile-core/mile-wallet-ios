//
//  WalleDetailsController.swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import SnapKit
import MileWalletKit

class WalletDetails: Controller {
    
    class Action {
        @objc var action:((_ sender:Any) -> ())?
        let title:String?
        let icon:UIImage?
        
        init(action:((_ sender:Any) -> ())?,title:String?,icon:UIImage?) {
            self.action = action
            self.title = title
            self.icon = icon
        }
    }
    
    public var qrFrame:CGRect = .zero
    
    public var walletKey:String? {
        didSet{
            if let w = walletKey {
                wallet = WalletStore.shared.wallet(by: w)
            }
        }
    }
    
    fileprivate lazy var actionDesc:[Action] = [
        Action(action: self.sendCoins,
               title: NSLocalizedString("Send", comment: ""),
               icon: UIImage(named: "button-send-coins")!),
        Action(action: printTicket,
               title: NSLocalizedString("Print", comment: ""),
               icon: UIImage(named: "button-print-ticket")!),
        Action(action: sendLink,
               title: NSLocalizedString("Link", comment: ""),
               icon: UIImage(named: "button-send-link")!),
        Action(action: sendInvoice,
               title: NSLocalizedString("Invoice", comment: ""),
               icon: UIImage(named: "button-send-invoice")!),
    ]
    
    @objc func sendCoins(_ sender:Any) {
        print("..... sendCoins \(sender)")

    }

    @objc func printTicket(_ sender:Any) {
        print("..... printTicket \(sender)")

    }

    @objc func sendLink(_ sender:Any) {
        print("..... sendLink \(sender)")
    }

    @objc func sendInvoice(_ sender:Any) {
        print("..... sendInvoice \(sender)")

    }
    
    private var wallet:WalletContainer? {
        didSet{
            bg.backgroundColor = UIColor(hex: wallet?.attributes?.color ?? 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "button-back"),
                                                           style: .plain, target: self, action: #selector(back(sender:)))
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "button-settings"),
                                                           style: .plain, target: self, action: #selector(settings(sender:)))
        
        if let walletKey = walletKey, let w = WalletStore.shared.wallet(by: walletKey) {
            wallet = w
            title = w.wallet?.name
            qrCode.image = w.wallet?.publicKeyQr
            bg.backgroundColor = UIColor(hex: w.attributes?.color ?? 0)
        }
        
        if let a = wallet?.attributes {
            if a.isActive {
                copyAddressButton.isUserInteractionEnabled = true
                qrContent.alpha = 1
                toolBar.alpha = 1
                toolBar.isUserInteractionEnabled = true
            }
            else {
                copyAddressButton.isUserInteractionEnabled = false
                qrContent.alpha = 0.5
                toolBar.alpha = 0.5
                toolBar.isUserInteractionEnabled = false
            }
        }
    }
    
    @objc private func back(sender:Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func settings(sender:Any) {
        _settingsWalletController.wallet = wallet
        present(_settingsWalletController, animated: true)
    }
    
    private let bg = UIImageView(image: Config.Images.basePattern)
    
    var actionH:CGFloat = 80
    let topPadding:CGFloat = 10
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
        if UIScreen.main.bounds.size.height < 640 {
            actionH = 60
        }
        
        contentView.addSubview(bg)
        bg.contentMode = .scaleAspectFill
        bg.snp.makeConstraints { (m) in
            m.edges.equalTo(view.snp.edges)
        }
        
        contentView.addSubview(qrContent)
        
        qrContent.addSubview(shadow)
        qrContent.addSubview(shadowBorder)
        qrContent.addSubview(qrCodeBorder)
        qrCodeBorder.addSubview(qrCode)
        
        contentView.addSubview(balance)
        contentView.addSubview(copyAddressButton)

        addChildViewController(walletInfo)
        balance.addSubview(walletInfo.view)
        walletInfo.didMove(toParentViewController: self)
        
        qrContent.snp.remakeConstraints { (m) in
            m.top.equalTo(contentView.snp.top).offset(0)
            m.left.right.equalTo(contentView).inset(0)
            m.height.equalTo(qrContent.snp.width)
        }
        
        qrCodeBorder.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(topPadding)
            m.left.equalToSuperview().offset(60)
            m.right.equalToSuperview().offset(-60)
            m.width.equalTo(qrCodeBorder.snp.height).multipliedBy(1/1)
        }
        
        shadow.snp.makeConstraints { (m) in
            m.edges.equalTo(qrCodeBorder.snp.edges)
                .inset(UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15))
        }
        
        shadowBorder.snp.makeConstraints { (m) in
            m.edges.equalTo(qrCodeBorder.snp.edges)
        }
        
        var h:CGFloat = 20
        if UIScreen.main.bounds.size.height < 640 {
            h = 10
        }
        
        qrCode.snp.makeConstraints { (m) in
            m.edges.equalTo(UIEdgeInsets(top: h, left: h, bottom: h, right: h))
        }
        
        balance.snp.remakeConstraints { (m) in
            //m.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top).offset(0).priority(.high)
            m.top.equalTo(qrCodeBorder.snp.bottom).offset(h)//.priority(.low)
            m.left.equalTo(contentView).inset(40)
            m.right.equalTo(contentView).inset(40)
            m.height.equalTo(120)
        }
        
        walletInfo.view.snp.remakeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        
        shadowSetup()
        
        toolBar.sizeToFit()
        
        contentView.addSubview(toolBar)
        
        var b:[UIBarButtonItem] = []
        for (i,a) in actionDesc.enumerated() {
            
            //b.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))

            let item = UIButton.toolBar(title: a.title,
                                        image: a.icon) { (sender) in
                                            a.action?(sender)
            }
            b.append(item)
            
            if i < actionDesc.count-1 {
                b.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
                let sep = Separator()
                b.append(UIBarButtonItem(customView: sep))
                b.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
            }
        }
        //b.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))

        toolBar.setItems(b, animated: false)
        
        h = 90
        if UIScreen.main.bounds.size.height < 640 {
            h = 70
        }
        
        toolBar.snp.makeConstraints { (m) in
            m.left.right.equalTo(view)
            m.bottom.equalTo(contentView.snp.bottom)
            m.height.equalTo(h)
        }
        
        toolBar.sizeToFit()

        
        copyAddressButton.snp.remakeConstraints { (m) in
            m.top.equalTo(balance.snp.bottom).offset(h).priority(.low)
            m.bottom.equalTo(toolBar.snp.top).offset(-20).priority(.high)
            m.left.right.equalTo(contentView).inset(60)
            m.height.equalTo(60)
        }
    }

    let toolBar:UIToolbar = {
        let toolBar = UIToolbar()
        
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.white
        toolBar.barTintColor = UIColor.white
        toolBar.isTranslucent = false
        toolBar.layer.borderColor = UIColor.clear.cgColor
        toolBar.setShadowImage(UIImage(), forToolbarPosition: .bottom)
        return toolBar
    }()
    
    public let qrContent:UIView = {
        let v = UIView()
        v.clipsToBounds = false
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    private let shadow:UIView = {
       let s = UIView()
        s.backgroundColor = UIColor.white
        return s
    }()
    
    private let shadowBorder:UIView = {
        let s = UIView()
        s.backgroundColor = UIColor.white
        return s
    }()
    
    private let qrCodeBorder:UIView = {
        let v = UIView()
        v.clipsToBounds = false
        v.backgroundColor = UIColor.white
        return v
    }()
    
    private let qrCode: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    fileprivate let balance:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    fileprivate lazy var copyAddressButton:UIButton = {
        let copy = UIButton(type: .custom)
        copy.setTitle(NSLocalizedString("Copy address", comment: ""), for: .normal)
        copy.setTitleColor(UIColor.white, for: .normal)
        copy.titleLabel?.font = Config.Fonts.caption
        copy.backgroundColor = Config.Colors.blueButton
        copy.layer.cornerRadius = Config.buttonRadius
        copy.addTarget(self, action: #selector(self.copyAddress(sender:)), for: .touchUpInside)
        return copy
    }()
    
    @objc func copyAddress(sender:UIButton){ 
        if let publicKey = wallet?.wallet?.publicKey {
            UIPasteboard.general.string = publicKey
        }
    }
    
    private func shadowSetup()  {
        shadow.layer.cornerRadius = 15
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadow.layer.shadowRadius = 10
        shadow.layer.shadowOpacity = 0.5
        
        qrCodeBorder.layer.cornerRadius = shadow.layer.cornerRadius
        shadowBorder.layer.cornerRadius = shadow.layer.cornerRadius
        
        shadowBorder.layer.shadowRadius = 8
        shadowBorder.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowBorder.layer.shadowColor = UIColor.black.cgColor
        shadowBorder.layer.shadowOpacity = 0.17
    }
    
    
    fileprivate var walletInfo:WalletInfo = WalletInfo()
    fileprivate var _settingsWalletController = WalletOptions()
}
