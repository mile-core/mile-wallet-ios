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

class Controller: UIViewController {
    
    public lazy var qrCodeReader:QRReader = {return QRReader(controller: self)}() 
    
    private let activiti = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private lazy var dimView = UIView(frame: self.view.bounds)        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Config.Colors.background
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
            }                    
        }
    }
    
    func loaderStop() {
        activiti.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: { 
            self.dimView.alpha=0
        }, completion: { (flag) in
            self.dimView.removeFromSuperview()
        })
    }        
}

public class NavigationController: UINavigationController {
}

