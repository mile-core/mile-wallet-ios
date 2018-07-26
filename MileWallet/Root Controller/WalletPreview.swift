//
//  WalletContentController.swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

class WalletCardPreview: WalletCell {
    
    public var walletIndex = 0 {
        didSet{
            
            let wallets = WalletStore.shared.acitveWallets
            
            let container = wallets[walletIndex]
            
            wallet = container.wallet
            walletAttributes = container.attributes
            
            qrCode.image = wallet?.publicKeyQr
            
            infoContainer.backgroundColor = UIColor(hex: 0x6679FD<<walletIndex*16)
            if let color = walletAttributes?.color {
                infoContainer.backgroundColor = UIColor(hex: color)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        content.addSubview(qrCode)
        content.addSubview(infoContainer)
        infoContainer.addSubview(line)
        infoContainer.addSubview(xdrLabel)
        infoContainer.addSubview(xdrAmountLabel)
        infoContainer.addSubview(mileLabel)
        infoContainer.addSubview(mileAmountLabel)

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
        
        line.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
            m.height.equalTo(1)
            m.width.equalToSuperview().offset(-40)
        }
        
        xdrAmountLabel.snp.makeConstraints { (m) in
            m.left.equalTo(infoContainer.snp.centerX).offset(10)
            m.right.equalTo(line.snp.right)
            m.height.equalTo(44)
            m.centerY.equalToSuperview().dividedBy(2)
        }

        mileAmountLabel.snp.makeConstraints { (m) in
            m.left.equalTo(infoContainer.snp.centerX).offset(10)
            m.right.equalTo(line.snp.right)
            m.height.equalTo(44)
            m.centerY.equalToSuperview().multipliedBy(1.5)
        }

        xdrLabel.snp.makeConstraints { (m) in
            m.left.equalTo(line.snp.left)
            m.right.equalTo(xdrAmountLabel.snp.left)
            m.height.equalTo(44)
            m.top.equalTo(xdrAmountLabel.snp.top)
        }
        
        mileLabel.snp.makeConstraints { (m) in
            m.left.equalTo(line.snp.left)
            m.right.equalTo(mileAmountLabel.snp.left)
            m.height.equalTo(44)
            m.top.equalTo(mileAmountLabel.snp.top)
        }             
    }
       
    private var firstTime = true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstTime {
            startActivities()
            
            self.mileInfoUpdate(error: { (error) in
                
                self.stopActivities()
                
                UIAlertController(title: NSLocalizedString("MILE blockchain error", comment: ""),
                                  message:  error?.description,
                                  preferredStyle: .alert)
                    .addAction(title: "Close", style: .cancel)
                    .present(by: self)
                
            }){ (chain) in
                self.chainInfo = chain
                self.update(timer: nil)
                
                DispatchQueue.main.async {
                    self.timerSetup()
                }
                
                self.firstTime = false
            }
        }
        else {
            self.timerSetup()
        }
    }
    
    private func  timerSetup(){
        reloadTimer?.invalidate()
        reloadTimer = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(self.update(timer:)),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.walletCell(self, didPresent: wallet)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reloadTimer?.invalidate()
        reloadTimer = nil
    }
    
    public var reloadTimer:Timer?
    
    @objc func update(timer:Timer?)  {
        
        guard let w = wallet, let chain = chainInfo else {return}
        
        Balance.update(wallet: w, error: { (error) in
            
            UIAlertController(title: NSLocalizedString("Balance error", comment: ""),
                              message:  error?.description,
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel)
                .present(by: self)
            
            self.stopActivities()
            
        }, complete: { (balance) in
            
            self.xdrAmountLabel.text = "0.00"
            self.mileAmountLabel.text = "0.00000"
            
            self.stopActivities()
                        
            for k in balance.balance.keys {
                if chain.assets[k] == "XDR" {
                    self.xdrAmountLabel.text = String(format: "%.2f", (Float(balance.balance[k] ?? "0") ?? 0.0))
                }
                else if chain.assets[k] == "MILE" {
                    self.mileAmountLabel.text = String(format: "%.5f", (Float(balance.balance[k] ?? "0") ?? 0.0))
                }
            }
        })
    }
    
    fileprivate let infoContainer:UIImageView = {
        let v = UIImageView(image: Config.Images.basePattern)
        v.contentMode = .scaleAspectFill
        return v
    }()
    
    fileprivate let line:UIView = {
        let v = UIView()
        v.backgroundColor = Config.Colors.line
        return v
    }()
    
    private let qrCode: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    private var xdrAmountLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.textColor = Config.Colors.name
        l.font = Config.Fonts.amount
        l.minimumScaleFactor = 0.5
        l.adjustsFontSizeToFitWidth = true
        return l
    }()
    
    private var mileAmountLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.textColor = Config.Colors.name
        l.font = Config.Fonts.amount
        l.minimumScaleFactor = 0.5
        l.adjustsFontSizeToFitWidth = true
        return l
    }()
    
    private var xdrLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.textColor = Config.Colors.name
        l.text = "XDR"
        l.font = Config.Fonts.name
        return l
    }()
    
    private var mileLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.textColor = Config.Colors.name
        l.text = "MILE"
        l.font = Config.Fonts.name
        return l
    }()
    
    
    private func activityLoader(place:UIView)  -> UIActivityIndicatorView {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .white)
        a.hidesWhenStopped = true
        place.addSubview(a)
        a.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return a
    }
    
    private func startActivities()  {
        for a in activities { a.startAnimating() }
    }
    
    private func stopActivities()  {
        for a in activities { a.stopAnimating() }
    }
    
    private lazy var activities:[UIActivityIndicatorView] = [self.activityLoader(place: self.xdrAmountLabel),
                                                             self.activityLoader(place: self.mileAmountLabel)]

}
