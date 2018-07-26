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

class WalletCardDetails: Controller {
    
    public var qrFrame:CGRect = .zero
    
    public var walletKey:String? {
        didSet{
            if let w = walletKey {
                wallet = WalletStore.shared.wallet(by: w)
            }
        }
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
        
        if let name = walletKey, let w = WalletStore.shared.wallet(by: name) {
            wallet = w
            title = w.wallet?.name
            qrCode.image = w.wallet?.publicKeyQr
            bg.backgroundColor = UIColor(hex: w.attributes?.color ?? 0)
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(bg)
        bg.contentMode = .scaleAspectFill
        bg.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.bottom.equalToSuperview()
        }
        
        shadow.backgroundColor = qrCodeBorder.backgroundColor
        shadowBorder.backgroundColor = qrCodeBorder.backgroundColor

        view.addSubview(scrollView)
        
        scrollView.delegate = self
        
        scrollView.addSubview(content)
        content.addSubview(shadow)
        content.addSubview(shadowBorder)
        content.addSubview(qrCodeBorder)
        qrCodeBorder.addSubview(qrCode)

        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Config.iPhoneX ? 30 : 10)
            m.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(0)
            m.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(0)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(0)
        }
        
        scrollView.contentSize = CGSize(width: view.bounds.size.width, height: 2000)
        
        content.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
        
        content.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            m.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(0)
            m.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(0)
        }
        
        qrCodeBorder.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(0)
            m.left.equalToSuperview().offset(40)
            m.right.equalToSuperview().offset(-40)
            m.width.equalTo(qrCode.snp.height).multipliedBy(1/1)
        }
        
        shadow.snp.makeConstraints { (m) in
            m.edges.equalTo(qrCodeBorder.snp.edges).inset(UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15))
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
        
        shadowSetup()
    }
    
    public let scrollView:UIScrollView = {
        let v = UIScrollView()
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    public let content:UIView = {
        let v = UIView()
        v.clipsToBounds = false
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    fileprivate let shadow = UIView()
    fileprivate let shadowBorder = UIView()
    
    public let qrCodeBorder:UIView = {
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
    
    fileprivate var _settingsWalletController = WalletOptionsController()
    fileprivate var baseQRCodeFrame:CGRect?
}


extension WalletCardDetails: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let desiredOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
            scrollView.setContentOffset(desiredOffset, animated: true)
        }
        else {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if qrCodeBorder.frame == .zero {return}
        if baseQRCodeFrame == nil {
            baseQRCodeFrame = qrCodeBorder.frame
        }
        let scale = (baseQRCodeFrame!.height-scrollView.contentOffset.y)/baseQRCodeFrame!.height
        content.transform = CGAffineTransform(scaleX: scale, y: scale)
        content.alpha = scale
    }
}
