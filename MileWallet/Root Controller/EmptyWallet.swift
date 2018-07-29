//
//  EmptyWallet.swift
//  MileWallet
//
//  Created by denn on 26.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import MileWalletKit

class EmptyWallet: WalletCell {
    
    var addWalletHandler:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        content.addSubview(cover)
        cover.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }
    
    fileprivate lazy var cover:UIView = {
        let v = UIView()
        
        let image = UIImage(named: "icon-new-wallet")!
        let icon = UIImageView(image: image)
        icon.contentMode = .scaleAspectFit
        v.addSubview(icon)
        icon.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            var h = 80
            if UIScreen.main.bounds.size.height < 640 {
                h = 40
            }
            m.top.equalToSuperview().offset(h)
            m.size.equalTo(image.size)
        })
        
        let header = UILabel()
        header.textAlignment = .center
        header.text = NSLocalizedString("Create your first MILE wallet!", comment: "")
        header.textColor = UIColor.black
        header.font = Config.Fonts.header
        header.numberOfLines = 4
        header.adjustsFontSizeToFitWidth = true
        header.minimumScaleFactor = 0.3
        
        let back = UIButton(type: .custom)
        back.setTitle(NSLocalizedString("Add wallet", comment: ""), for: UIControlState.normal)
        back.setTitleColor(UIColor.white, for: .normal)
        back.titleLabel?.font = Config.Fonts.caption
        back.backgroundColor = Config.Colors.blueButton
        back.layer.cornerRadius = Config.buttonRadius
        back.addTarget(self, action: #selector(addHandler(sender:)), for: UIControlEvents.touchUpInside)
        v.addSubview(back)
        back.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview().offset(-15)
            m.width.equalToSuperview().offset(-40)
            m.height.equalTo(60)
        })
        
        v.addSubview(header)
        header.sizeToFit()
        header.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(icon.snp.bottom).offset(20)
            m.bottom.lessThanOrEqualTo(back.snp.top).offset(-24)
            m.width.equalToSuperview().offset(-10)
        })
        
        return v
    }()
    
    @objc private func addHandler(sender:UIButton) {
        addWalletHandler?()
    }
}
