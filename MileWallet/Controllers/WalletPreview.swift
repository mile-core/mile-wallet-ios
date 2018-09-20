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
class WalletPreview: WalletCell {
    
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
    
        var color = UIColor(hex: 0x6679FD<<walletIndex*16)
        if let _c = walletAttributes?.color {
            color = UIColor(hex: _c)
        }
        infoContainer.backgroundColor = color
        setShadows(color: color.mix(infusion: UIColor.black, alpha: 0.3))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        content.addSubview(qrCode)
        content.addSubview(infoContainer)

        var h = 20
        if UIScreen.main.bounds.size.height < 640 {
            h = 10
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
    
    fileprivate var walletInfo:WalletInfo = WalletInfo()

    fileprivate let infoContainer:UIImageView = {
        let v = UIImageView(image: Config.Images.basePattern)
        v.contentMode = .scaleAspectFill
        return v
    }()
    
    private let qrCode: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
}
