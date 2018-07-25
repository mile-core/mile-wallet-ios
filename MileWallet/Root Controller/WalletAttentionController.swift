//
//  WalletAttentionController.swift
//  MileWallet
//
//  Created by denn on 25.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

class WalletAttentionController: Controller {
    
    var root:NewWalletControllerImp?
    var currentWallet:Wallet?
    var currentColor:UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attentionCover.frame = view.bounds
        attentionCover.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(attentionCover)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attentionCover.backgroundColor = self.currentColor
    }
    
    fileprivate lazy var attentionCover:UIView = {
        let v = UIView()
        let image = UIImageView(image: Config.Images.basePattern)
        image.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        image.frame = v.bounds
        v.addSubview(image)
        
        let pinterIcon = UIImageView(image: Config.Images.printerIcon)
        v.addSubview(pinterIcon)
        pinterIcon.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.top.equalToSuperview().offset(140)
            m.size.equalTo(Config.Images.printerIcon.size)
        })
        
        let header = UILabel()
        header.textAlignment = .center
        header.text = NSLocalizedString("Important!", comment: "")
        header.textColor = Config.Colors.header
        header.font = Config.Fonts.header
        
        v.addSubview(header)
        header.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(pinterIcon.snp.bottom).offset(24)
            m.width.equalToSuperview()
        })
        
        let back = UIButton(type: .custom)
        back.setTitle(NSLocalizedString("Back to main screen", comment: ""), for: UIControlState.normal)
        back.setTitleColor(Config.Colors.back, for: .normal)
        back.titleLabel?.font = Config.Fonts.caption
        back.backgroundColor = UIColor.white
        back.layer.cornerRadius = 8
        back.addTarget(self, action: #selector(backMainHandler(sender:)), for: UIControlEvents.touchUpInside)
        v.addSubview(back)
        back.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview().offset(-15)
            m.width.equalToSuperview().offset(-40)
            m.height.equalTo(60)
        })
        
        let text = UITextView()
        text.backgroundColor = UIColor.clear
        text.isUserInteractionEnabled = false
        text.textAlignment = .center
        text.textContainer.lineBreakMode = .byWordWrapping
        text.textContainer.maximumNumberOfLines = 5
        text.isSelectable = true
        text.isScrollEnabled = false
        text.layer.borderWidth = 0.0
        text.font = Config.Fonts.caption
        text.clearsOnInsertion = true
        text.textColor = UIColor.white
        text.resignFirstResponder()
        
        text.text = NSLocalizedString("You should SAVE your public and private key or you will not have a chance to restore your wallet!", comment: "")
        
        let textContainer = UIView()
        textContainer.backgroundColor = Config.Colors.attentionText
        textContainer.layer.cornerRadius = 8
        textContainer.clipsToBounds = true
        
        v.addSubview(textContainer)
        
        textContainer.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalTo(back.snp.top).offset(-10)
            m.width.equalToSuperview().offset(-40)
            m.height.equalTo(211)
        })
        
        textContainer.addSubview(text)
        
        text.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview().offset(-60)
            m.width.equalToSuperview().offset(-40)
            m.top.equalToSuperview().offset(24)
        })
        
        let line = UIView()
        line.backgroundColor = UIColor.white.withAlphaComponent(0.13)
        textContainer.addSubview(line)
        
        line.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview().offset(-59)
            m.width.equalToSuperview()
            m.height.equalTo(1)
        })
        
        let print = UIButton(type: .custom)
        print.setTitle(NSLocalizedString("Print Wallet Secret Paper", comment: ""), for: UIControlState.normal)
        print.setTitleColor(UIColor.white, for: .normal)
        print.titleLabel?.font = Config.Fonts.caption
        print.backgroundColor = UIColor.clear
        print.addTarget(self, action: #selector(printHandler(sender:)), for: UIControlEvents.touchUpInside)
        textContainer.addSubview(print)
        
        print.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview()
            m.width.equalToSuperview()
            m.top.equalTo(line.snp.bottom)
        })
        
        return v
    }()
    
    @objc fileprivate func backMainHandler(sender:UIButton){
        self.view.alpha = 0
        self.dismiss(animated: false) {
            self.root?.dismiss(animated: false) {
                
            }
        }
        //self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc fileprivate func printHandler(sender:UIButton){
        
        loaderStart()
        Printer.shared.printController.delegate = self
        Printer.shared.printPDF(wallet: currentWallet,
                                formater: { return HTMLTemplate.get(wallet:$0) },
                                complete: { _,complete,_ in
                                    self.loaderStop()
        })
    }
    
}

extension WalletAttentionController: UIPrintInteractionControllerDelegate {
    func printInteractionControllerParentViewController(_ printInteractionController: UIPrintInteractionController) -> UIViewController? {
        return self
    }
}
