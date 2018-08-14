//
//  Controller.swift
//  MileWallet
//
//  Created by denis svinarchuk on 14.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import MileWalletKit
import KeychainAccess

extension UIViewController {    
    func presentInNavigationController(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        let nc =  NavigationController()
        nc.view.backgroundColor = Config.Colors.defaultColor
        nc.setViewControllers([viewControllerToPresent], animated: true)
        if let root = self.navigationController {
            root.present(nc,
                         animated: flag,
                         completion: completion)
        }
        else {
            present(nc,
                    animated: flag,
                    completion: completion)
        }
    }
}

class Controller: UIViewController {

    public var chainInfo:Chain?

    public lazy var qrCodeReader:QRReader = {return QRReader(controller: self)}() 
    
    public let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(__didNetworkChangeStatus(notification:)),
                         name: NSNotification.Name("NetworkIsReachable"),
                         object: nil)

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(__didNetworkChangeStatus(notification:)),
                         name: NSNotification.Name("NetworkIsUnreachable"),
                         object: nil)

        view.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (m) in
            if navigationController != nil {
                m.top.equalTo(view.snp.topMargin)
            }
            else {
                m.top.equalToSuperview()
            }
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.bottom.equalToSuperview()
        }
    }
    
    public func notifyNetworkStatus(reachable:Bool) {
        DispatchQueue.main.async {
            let status = reachable ?  NSNotification.Name("NetworkIsReachable") : NSNotification.Name("NetworkIsUnreachable")
            NotificationCenter.default.post(name: status, object: nil)
        }
    }
    
    public func didNetworkChangeStatus(reachable:Bool){}

    private var lastNetworkStatus = false
    
    private func __didNetworkChangeStatus(reachable:Bool){
         DispatchQueue.main.async {
            guard self.lastNetworkStatus != reachable else { return  }
            self.lastNetworkStatus = reachable
            self.didNetworkChangeStatus(reachable: reachable)
        }
        
    }

    @objc private func __didNetworkChangeStatus(notification:Notification) {
        if notification.name == NSNotification.Name("NetworkIsReachable") {
            __didNetworkChangeStatus(reachable: true)
        }
        else {
            __didNetworkChangeStatus(reachable: false)
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if presentingViewController is UINavigationController {
            super.dismiss(animated: true, completion: nil)
        } else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    func loaderStart()  {
        DispatchQueue.main.async {
            self.dimView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            self.dimView.alpha = 0
            
            self.view.addSubview(self.dimView)
            
            self.activiti.hidesWhenStopped = true        
            self.activiti.startAnimating()        
            self.dimView.addSubview(self.activiti)
            
            self.dimView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            UIView.animate(withDuration: 0.1) { 
                self.dimView.alpha = 1
            }
            
            self.activiti.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.height.equalTo(60)
                make.width.equalTo(self.activiti.snp.height)
            }                    
        }
    }
    
    func loaderStop() {
        DispatchQueue.main.async {
            self.activiti.stopAnimating()
            UIView.animate(withDuration: 0.2, animations: {
                self.dimView.alpha=0
            }, completion: { (flag) in
                self.dimView.removeFromSuperview()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loaderStop()
        view.endEditing(true)
    }
    
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
    
    private let activiti = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private lazy var dimView = UIView(frame: self.view.bounds)
    
    private var passcodeScreen = PasscodeScreen()
    
    public func presentPasscodeScreen(){
        
        if PasscodeScreen.isUnlocked || PasscodeScreen.isPresenting { return }
        
        if !PasscodeStrore.shared.isRegistered {

            if self.passcodeScreen.presentingViewController != nil {
                self.passcodeScreen.dismiss(animated: false)
            }
            
            UIAlertController(title: NSLocalizedString("Security Alert", comment: ""),
                              message: NSLocalizedString("To avoid insecure access MILE Wallet please configure access with passcode", comment: ""),
                              preferredStyle: .actionSheet)
                .addAction(title: NSLocalizedString("Cancel", comment: ""),
                           style: UIAlertActionStyle.cancel) { (action) in
                            PasscodeScreen.isUnlocked = true
                }
                .addAction(title: NSLocalizedString("Open passcode settings", comment: ""),
                           style: .default, handler: { (action) in
                            self.passcodeScreen.settingsMode = true
                            self.present(self.passcodeScreen, animated: false) 
                })
                .present(by: self)
        }
    }
}

public class NavigationController: UINavigationController {
    
    public var titleColor:UIColor = Config.Colors.defaultColor {
        didSet{
            bg.backgroundColor = titleColor
        }
    }
    
    public override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        if !hidden {
            bg.snp.remakeConstraints { (m) in
                m.top.equalToSuperview()
                m.left.equalToSuperview()
                m.right.equalToSuperview()
                m.bottom.equalTo(navigationBar.snp.bottom)
            }
        }
    }
    
    private let bg = UIImageView(image: Config.Images.basePattern)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar
            .titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: Config.Colors.navigationBarTitle,
             NSAttributedStringKey.font: Config.Fonts.navigationBarTitle]
        
        navigationBar
            .largeTitleTextAttributes =
            [NSAttributedStringKey.foregroundColor: Config.Colors.navigationBarLargeTitle,
             NSAttributedStringKey.font: Config.Fonts.navigationBarLargeTitle]
        
        navigationBar.barStyle = .default
        navigationBar.tintColor = UIColor.white
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        navigationBar.prefersLargeTitles = true
        
        view.insertSubview(bg, at: 0)
        bg.backgroundColor = titleColor
        bg.contentMode = .scaleAspectFill
        bg.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.bottom.equalTo(navigationBar.snp.bottom)
        }
    }        
}

