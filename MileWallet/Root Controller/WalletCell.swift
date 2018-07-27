//
//  WalletCellController.swift
//  MileWallet
//
//  Created by denn on 26.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

protocol WalletCellDelegate {
    func walletCell(_ item: WalletCell, didPress wallet:WalletContainer?)
    func walletCell(_ item: WalletCell, didPresent wallet:WalletContainer?)
}

extension WalletCellDelegate {
    func walletCell(_ item: WalletCell, didPress:WalletContainer?){}
    func walletCell(_ item: WalletCell, didPresent wallet:WalletContainer?){}
}

class WalletCell: Controller {
    
    public var wallet:Wallet?
    public var walletAttributes:WalletAttributes?
    
    public var delegate:WalletCellDelegate?
      
    
    public let content:UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    fileprivate let shadow = UIView()
    fileprivate let shadowBorder = UIView()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        content.backgroundColor = UIColor.white
        shadow.backgroundColor = content.backgroundColor
        shadowBorder.backgroundColor = content.backgroundColor
        
        view.addSubview(shadow)
        view.addSubview(shadowBorder)
        view.addSubview(content)
        
        shadow.snp.makeConstraints { (m) in
            m.edges.equalTo(content.snp.edges).inset(UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15))
        }
        
        shadowBorder.snp.makeConstraints { (m) in
            m.edges.equalTo(content.snp.edges)
        }
        
        content.snp.makeConstraints { (m) in
            m.edges.equalTo(UIEdgeInsets(top: 10, left: 40, bottom: 30, right: 40))
        }
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(pressContentHandler(gesture:)))
        press.minimumPressDuration = 0.2
        press.numberOfTapsRequired = 0
        press.numberOfTouchesRequired = 1
        press.cancelsTouchesInView = true
        content.addGestureRecognizer(press)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shadowSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.walletCell(self, didPresent:  WalletContainer(wallet: self.wallet,
                                                                attributes: self.walletAttributes))
    }
    
    @objc private func pressContentHandler(gesture:UILongPressGestureRecognizer){
        if gesture.state == .began {
            CATransaction.begin()
            CATransaction.setAnimationDuration(UIView.inheritedAnimationDuration)
            self.shadow.layer.shadowRadius = 5
            self.shadow.layer.shadowOffset = CGSize(width: 0, height: 4)
            self.shadow.layer.shadowOpacity = 0.3
            CATransaction.setCompletionBlock {
                self.delegate?.walletCell(self, didPress: WalletContainer(wallet: self.wallet,
                                                                          attributes: self.walletAttributes))
            }
            CATransaction.commit()
        }
    }
    
    private func shadowSetup()  {
        shadow.layer.cornerRadius = 15
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadow.layer.shadowRadius = 10
        shadow.layer.shadowOpacity = 0.5
        
        content.layer.cornerRadius = shadow.layer.cornerRadius
        shadowBorder.layer.cornerRadius = shadow.layer.cornerRadius
        
        shadowBorder.layer.shadowRadius = 8
        shadowBorder.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowBorder.layer.shadowColor = UIColor.black.cgColor
        shadowBorder.layer.shadowOpacity = 0.17
    }
}
