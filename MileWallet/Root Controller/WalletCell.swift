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
    func walletCell(_ item: WalletCell, didPress wallet:Wallet?)
    func walletCell(_ item: WalletCell, didPresent wallet:Wallet?)
}

extension WalletCellDelegate {
    func walletCell(_ item: WalletCell, didPress:Wallet?){}
    func walletCell(_ item: WalletCell, didPresent wallet:Wallet?){}
}

class WalletCell: Controller {
    
    public var chainInfo:Chain?
    public var wallet:Wallet?
    public var walletAttributes:WalletAttributes?
    
    public var delegate:WalletCellDelegate?
    
    public func mileInfoUpdate(error: ((_ error: Error?)-> Void)?=nil,
                               complete:@escaping ((_ chain:Chain)->Void))  {
        
        if chainInfo == nil {
            Chain.update(error: { (e) in
                
                error?(e)
                
            }) { (chain) in
                self.chainInfo = chain
                complete(self.chainInfo!)
            }
        }
        
        guard let chain = chainInfo else {
            return
        }
        
        complete(chain)
    }
    
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
            m.edges.equalTo(UIEdgeInsets(top: 30, left: 55, bottom: 30, right: 55))
        }
        
        shadowBorder.snp.makeConstraints { (m) in
            m.edges.equalTo(UIEdgeInsets(top: 10, left: 40, bottom: 30, right: 40))
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
        
    @objc private func pressContentHandler(gesture:UILongPressGestureRecognizer){
        if gesture.state == .began {
            CATransaction.begin()
            CATransaction.setAnimationDuration(UIView.inheritedAnimationDuration)
            self.shadow.layer.shadowRadius = 5
            self.shadow.layer.shadowOffset = CGSize(width: 0, height: 4)
            self.shadow.layer.shadowOpacity = 0.3
            CATransaction.setCompletionBlock {
                self.delegate?.walletCell(self, didPress: self.wallet)
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
