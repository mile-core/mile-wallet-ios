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
    
    public static let shadowsPulseKey = "shadowsPulseKey"

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
        
        operations.maxConcurrentOperationCount = 1

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
            if UIDevice().userInterfaceIdiom == .pad {
                m.edges.equalTo(UIEdgeInsets(top: 10, left: 80, bottom: 30, right: 80))
            }
            else {
                m.edges.equalTo(UIEdgeInsets(top: 10, left: 40, bottom: 30, right: 40))
            }
        }
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(pressContentHandler(gesture:)))
        press.minimumPressDuration = 0.2
        press.numberOfTapsRequired = 0
        press.numberOfTouchesRequired = 1
        press.cancelsTouchesInView = true
        content.addGestureRecognizer(press)
        
        currentPushingCount = UserDefaults.standard.integer(forKey: WalletCell.shadowsPulseKey)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetCounters(notification:)),
                                               name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc private func resetCounters(notification:Notification) {
        currentPushingCount = UserDefaults.standard.integer(forKey: WalletCell.shadowsPulseKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        deferredOperations?.invalidate()
        operations.cancelAllOperations()

        shadowSetup(alpha: 1)
    }
    
    private var operations = OperationQueue()
    private var deferredOperations:Timer?
    private var currentPushingCount = 0
    
    @objc private func deferredOperationsHandler(timer:Timer) {
        self.operations.cancelAllOperations()
        self.operations.addOperation {
            for _ in 0..<5 {
                self.shadowsPulse()
                sleep(3)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.walletCell(self, didPresent:  WalletContainer(wallet: self.wallet,
                                                                attributes: self.walletAttributes))
        
        
        guard WalletStore.shared.acitveWallets.count > 0 else { return }
        
        if UserDefaults.standard.integer(forKey: WalletCell.shadowsPulseKey) < 5 {
            if UserDefaults.standard.integer(forKey: WalletCell.shadowsPulseKey) > currentPushingCount {
                return
            }
            deferredOperations = Timer.scheduledTimer(timeInterval: 1,
                                                      target: self,
                                                      selector: #selector(deferredOperationsHandler(timer:)),
                                                      userInfo: nil, repeats: false)
          
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deferredOperations?.invalidate()
        operations.cancelAllOperations()
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
    
    private func makePulse(keyPath:String, alpha:Float) -> CABasicAnimation {
        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: keyPath)
        pulseAnimation.duration = 0.12
        pulseAnimation.toValue = NSNumber(value: alpha)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = 3
        return pulseAnimation
    }
    
    private func shadowsPulse() {
        DispatchQueue.main.async {
            let pulseAnimation:CABasicAnimation = self.makePulse(keyPath: "transform.scale", alpha: 0.95)
            
            self.shadow.layer.add(pulseAnimation, forKey: nil)
            self.shadowBorder.layer.add(pulseAnimation, forKey: nil)
            
            self.view.layer.add(self.makePulse(keyPath: "transform.scale", alpha: 0.998), forKey: nil)
        }
    }
    
    internal func setShadows(color:UIColor)  {
        shadow.backgroundColor = color
        shadowBorder.backgroundColor = color
        shadow.layer.shadowColor = color.cgColor
        shadowBorder.layer.shadowColor = color.cgColor
    }
    
    private func shadowSetup(alpha:CGFloat)  {
        shadow.layer.cornerRadius = 15
        shadow.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadow.layer.shadowRadius = 10 * alpha
        shadow.layer.shadowOpacity = Float(0.5 * alpha)
        
        content.layer.cornerRadius = shadow.layer.cornerRadius
        shadowBorder.layer.cornerRadius = shadow.layer.cornerRadius
        
        shadowBorder.layer.shadowRadius = 6 * alpha
        shadowBorder.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowBorder.layer.shadowOpacity = Float(0.13 * alpha)
        setShadows(color:UIColor.black)
    }
}
