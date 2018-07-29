//
//  WalletInfo.swift
//  MileWallet
//
//  Created by denn on 27.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

class WalletInfo: Controller {
    
    private static var balancesCache:[String:Balance] = [:]
    
    public var wallet:WalletContainer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(line)
        view.addSubview(xdrLabel)
        view.addSubview(xdrAmountLabel)
        view.addSubview(mileLabel)
        view.addSubview(mileAmountLabel)
        
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
        
        line.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
            m.height.equalTo(1)
            m.width.equalToSuperview().offset(-40)
        }
        
        xdrAmountLabel.snp.makeConstraints { (m) in
            m.left.equalTo(view.snp.centerX).dividedBy(2).offset(20)
            m.right.equalTo(line.snp.right)
            m.height.equalTo(44)
            m.centerY.equalToSuperview().dividedBy(2)
        }
        
        mileAmountLabel.snp.makeConstraints { (m) in
            m.left.equalTo(xdrAmountLabel.snp.left)
            m.right.equalTo(line.snp.right)
            m.height.equalTo(44)
            m.centerY.equalToSuperview().multipliedBy(1.5)
        }
    }
    
    private var firstTime = true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        if let k = wallet?.wallet?.publicKey, let b = WalletInfo.balancesCache[k] {
            update(balance: b)
        }
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reloadTimer?.invalidate()
        reloadTimer = nil
    }
    
    fileprivate let line:UIView = {
        let v = UIView()
        v.backgroundColor = Config.Colors.line
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
        l.text = Asset.xdr.name
        l.font = Config.Fonts.name
        return l
    }()
    
    private var mileLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.textColor = Config.Colors.name
        l.text = Asset.mile.name
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
    
    public var reloadTimer:Timer?
    
    public func update(balance: Balance) {
        
        guard let chain = chainInfo else {return}

        self.xdrAmountLabel.text = Asset.xdr.stringValue(0)
        self.mileAmountLabel.text = Asset.mile.stringValue(0)
        
        self.stopActivities()
        
        for k in balance.balance.keys {
            let b = Float(balance.balance[k] ?? "0") ?? 0
            if chain.assets[k] == Asset.xdr.name {
                self.xdrAmountLabel.text = Asset.xdr.stringValue(b)
            }
            else if chain.assets[k] == Asset.mile.name {
                self.mileAmountLabel.text = Asset.mile.stringValue(b)
            }
        }
    }
    
    @objc private func update(timer:Timer?)  {
        
        guard let w = wallet?.wallet else {return}
                
        Balance.update(wallet: w, error: { (error) in
            
            UIAlertController(title: NSLocalizedString("Balance error", comment: ""),
                              message:  error?.description,
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel)
                .present(by: self)
            
            self.stopActivities()
            
        }, complete: { (balance) in
            self.update(balance: balance)
            WalletInfo.balancesCache[w.publicKey!] = balance
        })
    }
}
