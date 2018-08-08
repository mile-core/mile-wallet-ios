//
//  WalletContentController.swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit


///
/// View wallet in page controller as preview
///
class WalletCardPreview: WalletCell {
    
    public var walletIndex = 0 {
        didSet{
            updateWallet()
            qrCode.image = wallet?.publicKeyQr
        }
    }
    
    fileprivate func updateWallet(){
        
        let wallets = WalletStore.shared.acitveWallets
        
        let container = wallets[walletIndex]

        walletInfo.wallet = container
        
        wallet = container.wallet
        walletAttributes = container.attributes
    
        infoContainer.backgroundColor = UIColor(hex: 0x6679FD<<walletIndex*16)
        if let color = walletAttributes?.color {
            infoContainer.backgroundColor = UIColor(hex: color)
        }
    }
    
    private let firstWalletKey = "TheFirtsOpenOfTheWallet"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        content.addSubview(openTheWalletOnce)
        content.addSubview(qrCode)
        content.addSubview(infoContainer)

        var h = 20
        if UIScreen.main.bounds.size.height < 640 {
            h = 10
        }
        
        openTheWalletOnce.snp.makeConstraints { (m) in
            m.center.equalTo(qrCode)
            m.right.equalToSuperview().offset(-20)
            m.left.equalToSuperview().offset(20)
            m.height.equalTo(100)
        }
        
        if !UserDefaults.standard.bool(forKey: firstWalletKey) {
            qrCode.alpha = 0.08
        }
        
        qrCode.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(h)
            m.left.equalToSuperview().offset(h)
            m.right.equalToSuperview().offset(-h)
            m.width.equalTo(qrCode.snp.height).multipliedBy(1/1)
        }

        infoContainer.snp.makeConstraints { (m) in
            m.top.equalTo(qrCode.snp.bottom).offset(h)
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.bottom.equalToSuperview()
        }
        
        addChildViewController(walletInfo)
        infoContainer.addSubview(walletInfo.view)
        walletInfo.didMove(toParentViewController: self)

        walletInfo.view.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWallet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: firstWalletKey) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.qrCode.alpha = 1
                    self.openTheWalletOnce.alpha = 0
                }) { flag in
                    
                    UserDefaults.standard.set(true, forKey: self.firstWalletKey)
                    UserDefaults.standard.synchronize()
                    
                }
            }
        }
    }
    
    fileprivate var walletInfo:WalletInfo = WalletInfo()

    fileprivate let infoContainer:UIImageView = {
        let v = UIImageView(image: Config.Images.basePattern)
        v.contentMode = .scaleAspectFill
        return v
    }()
   
    private let openTheWalletOnce: UILabel = {
        let v = UILabel()
        v.textColor = Config.Colors.placeHolder
        v.font = Config.Fonts.caption
        v.text = NSLocalizedString("To open the wallet: tap the area!", comment: "")
        v.numberOfLines = 2
        v.adjustsFontSizeToFitWidth = true
        v.alpha = 0.8
        v.textAlignment = .center
        return v
    }()
    
    private let qrCode: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
}
