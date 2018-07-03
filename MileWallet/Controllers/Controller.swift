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
//    static var keychain:Keychain {
//        return Keychain(accessGroup: Config.walletService).synchronizable(Config.isWalletKeychainSynchronizable)
//    }
}

class Controller: UIViewController {
    
//    var keychain:Keychain {
//        return Keychain(accessGroup: Config.walletService).synchronizable(Config.isWalletKeychainSynchronizable)
//    }

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
    
    
//    lazy var printInfo:UIPrintInfo = {
//        let p = UIPrintInfo(dictionary:nil)
//        p.outputType = UIPrintInfoOutputType.general
//        p.duplex = .longEdge
//        p.orientation = .portrait        
//        p.jobName = NSLocalizedString("Wallet printer job", comment: "")
//        return p
//    }()
//
//    
//    lazy var printController:UIPrintInteractionController = {
//        let p = UIPrintInteractionController.shared                
//        p.printInfo = printInfo
//        return p
//    }()
//    
//    func printPDF(wallet:Wallet?,
//                  formater:@escaping ((_ wallet:Wallet)->String), 
//                  complete:((UIPrintInteractionController, Bool, Error?)->Void)?) {
//        
//        guard let wallet = wallet else {
//            complete?(printController, false, nil)
//            return
//        }
//        
//        loaderStart()
//        
//        DispatchQueue.global().async {
//            let str = formater(wallet)
//            DispatchQueue.main.async {
//                let pdf = UIMarkupTextPrintFormatter(markupText: str)
//                PDF.generate(using: pdf)
//                self.printController.printFormatter = pdf
//                self.printController.present(animated: true) { (controller, completed, error) in
//                    complete?(controller,completed,error)
//                    self.loaderStop()
//                }                    
//            }
//        }
//    }    
}
