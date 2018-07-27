//
//  WalleDetailsController.swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import SnapKit
import MileWalletKit

class WalletCardDetails: Controller {
    
    class Action {
        @objc var action:((_ sender:Any) -> ())?
        let title:String?
        let icon:UIImage?
        
        init(action:((_ sender:Any) -> ())?,title:String?,icon:UIImage?) {
            self.action = action
            self.title = title
            self.icon = icon
        }
    }
    
    public var qrFrame:CGRect = .zero
    
    public var walletKey:String? {
        didSet{
            if let w = walletKey {
                wallet = WalletStore.shared.wallet(by: w)
            }
        }
    }
    
    fileprivate lazy var actionDesc:[Action] = [
        Action(action: self.sendCoins,
               title: NSLocalizedString("Send coins", comment: ""),
               icon: UIImage(named: "button-send-coins")!),
        Action(action: sendCoins,
               title: NSLocalizedString("Print payment ticket", comment: ""),
               icon: UIImage(named: "button-print-ticket")!),
        Action(action: sendCoins,
               title: NSLocalizedString("Send payment link", comment: ""),
               icon: UIImage(named: "button-send-link")!),
        Action(action: sendCoins,
               title: NSLocalizedString("Send invoice", comment: ""),
               icon: UIImage(named: "button-send-invoice")!),
    ]
    
    @objc func sendCoins(_ sender:Any) {
        print("..... sendCoins \(sender)")

    }

    @objc func printTicket(_ sender:Any) {
        print("..... printTicket \(sender)")

    }

    @objc func sendLink(_ sender:Any) {
        print("..... sendLink \(sender)")
    }

    @objc func sendInvoice(_ sender:Any) {
        print("..... sendInvoice \(sender)")

    }

    
    private var wallet:WalletContainer? {
        didSet{
            bg.backgroundColor = UIColor(hex: wallet?.attributes?.color ?? 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "button-back"),
                                                           style: .plain, target: self, action: #selector(back(sender:)))
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "button-settings"),
                                                           style: .plain, target: self, action: #selector(settings(sender:)))
        
        if let name = walletKey, let w = WalletStore.shared.wallet(by: name) {
            wallet = w
            title = w.wallet?.name
            qrCode.image = w.wallet?.publicKeyQr
            bg.backgroundColor = UIColor(hex: w.attributes?.color ?? 0)
        }
        
    
    }
    
    @objc private func back(sender:Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func settings(sender:Any) {
        _settingsWalletController.wallet = wallet
        present(_settingsWalletController, animated: true)
    }
    
    private let bg = UIImageView(image: Config.Images.basePattern)
    
    var actionH:CGFloat = 80
    let topPadding:CGFloat = 10

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
     
        let height = contentView.frame.height
        
        wrapperView.snp.makeConstraints { (m) in
            m.top.equalTo(scrollView)
            m.bottom.equalTo(scrollView).offset(-(actionH*4+4 + height))
            m.left.right.equalTo(contentView)
        }
        
        qrContent.snp.remakeConstraints { (m) in
            m.top.equalTo(wrapperView.snp.top).offset(0)
            m.left.right.equalTo(wrapperView).inset(0)
            m.height.equalTo(height-topPadding)
        }
                
        qrCodeBorder.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(topPadding)
            m.left.equalToSuperview().offset(60)
            m.right.equalToSuperview().offset(-60)
            m.width.equalTo(qrCodeBorder.snp.height).multipliedBy(1/1)
        }

        shadow.snp.makeConstraints { (m) in
            m.edges.equalTo(qrCodeBorder.snp.edges)
                .inset(UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15))
        }
        
        shadowBorder.snp.makeConstraints { (m) in
            m.edges.equalTo(qrCodeBorder.snp.edges)
        }
        
        var h:CGFloat = 20
        if UIScreen.main.bounds.size.height < 640 {
            h = 10
        }
        
        qrCode.snp.makeConstraints { (m) in
            m.edges.equalTo(UIEdgeInsets(top: h, left: h, bottom: h, right: h))
        }
        
        balance.snp.remakeConstraints { (m) in
            m.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top).offset(0).priority(.high)
            m.top.equalTo(qrCodeBorder.snp.bottom).offset(40).priority(.low)
            m.left.equalTo(wrapperView).inset(40)
            m.right.equalTo(wrapperView).inset(40)
            m.height.equalTo(120)
        }
        
        actions.snp.remakeConstraints { (m) in
            m.top.greaterThanOrEqualTo(copyAddressButton.snp.bottom).offset(5).priority(.high)
            m.top.equalTo(wrapperView.snp.top).offset(height).priority(.low)
            m.left.right.equalTo(wrapperView).inset(0)
            m.height.equalTo(actionH*4+4+topPadding).priority(.low)
            m.bottom.greaterThanOrEqualTo(view.snp.bottom).priority(.high)
        }
        
        copyAddressButton.snp.remakeConstraints { (m) in
            m.top.greaterThanOrEqualTo(balance.snp.bottom).offset(0).priority(.high)
            m.bottom.equalTo(actions.snp.top).offset(-40).priority(.low)
            m.left.right.equalTo(wrapperView).inset(60)
            m.height.equalTo(60)
        }
        
        walletInfo.view.snp.remakeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        
        shadowSetup()
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
        if UIScreen.main.bounds.size.height < 640 {
            actionH = 60
        }
        
        contentView.addSubview(bg)
        bg.contentMode = .scaleAspectFill
        bg.snp.makeConstraints { (m) in
            m.edges.equalTo(view.snp.edges)
        }
        
        scrollView.showsVerticalScrollIndicator = false
        contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        scrollView.addSubview(wrapperView)
        
        wrapperView.addSubview(qrContent)
        
        qrContent.addSubview(shadow)
        qrContent.addSubview(shadowBorder)
        qrContent.addSubview(qrCodeBorder)
        qrCodeBorder.addSubview(qrCode)
        
        wrapperView.addSubview(balance)
        wrapperView.addSubview(actions)
        wrapperView.addSubview(copyAddressButton)

        addChildViewController(walletInfo)
        balance.addSubview(walletInfo.view)
        walletInfo.didMove(toParentViewController: self)
        
        scrollView.delegate = self
    }
    
    public let scrollView:UIScrollView = {
        let v = UIScrollView()
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    public let qrContent:UIView = {
        let v = UIView()
        v.clipsToBounds = false
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    let wrapperView = UIView()
    
    private let shadow:UIView = {
       let s = UIView()
        s.backgroundColor = UIColor.white
        return s
    }()
    
    private let shadowBorder:UIView = {
        let s = UIView()
        s.backgroundColor = UIColor.white
        return s
    }()
    
    private let qrCodeBorder:UIView = {
        let v = UIView()
        v.clipsToBounds = false
        v.backgroundColor = UIColor.white
        return v
    }()
    
    private let qrCode: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    fileprivate lazy var actions:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        var prev = v
        
        var y:CGFloat = 0
        for (i,a) in self.actionDesc.enumerated() {
            
            let button = UIButton(type: .custom)
            button.backgroundColor = UIColor.clear
            button.setTitle(a.title, for: .normal)
            button.contentHorizontalAlignment = .left
            button.titleLabel?.textAlignment = .left
            button.titleLabel?.font = Config.Fonts.caption
            button.titleLabel?.textColor = UIColor.blue
            button.frame = CGRect(x: 21, y: y, width: self.view.bounds.width, height: self.actionH)
            button.tag = i
            button.addTarget(self, action: #selector(actionsHandler(_:)), for: .touchUpInside)
            y += self.actionH
            v.addSubview(button)
        }

        return v
    }()
    
    @objc func actionsHandler(_ sender:UIButton){
        printTicket("actionsHandler ... > \(sender.tag)")
    }
    
    fileprivate let balance:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    fileprivate let copyAddressButton:UIButton = {
        let back = UIButton(type: .custom)
        back.setTitle(NSLocalizedString("Copy address", comment: ""), for: UIControlState.normal)
        back.setTitleColor(UIColor.white, for: .normal)
        back.titleLabel?.font = Config.Fonts.caption
        back.backgroundColor = Config.Colors.blueButton
        back.layer.cornerRadius = Config.buttonRadius
        return back
    }()
    
    private func shadowSetup()  {
        shadow.layer.cornerRadius = 15
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadow.layer.shadowRadius = 10
        shadow.layer.shadowOpacity = 0.5
        
        qrCodeBorder.layer.cornerRadius = shadow.layer.cornerRadius
        shadowBorder.layer.cornerRadius = shadow.layer.cornerRadius
        
        shadowBorder.layer.shadowRadius = 8
        shadowBorder.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowBorder.layer.shadowColor = UIColor.black.cgColor
        shadowBorder.layer.shadowOpacity = 0.17
    }
    
    
    fileprivate var walletInfo:WalletInfo = WalletInfo()
    fileprivate var _settingsWalletController = WalletOptionsController()
    fileprivate var baseQRCodeFrame:CGRect?
    fileprivate var baseActionsFrame:CGRect = .zero

    fileprivate var qrCodeScale:CGFloat = 1
    fileprivate var scrollVelocity:CGPoint = .zero
}


extension WalletCardDetails: UIScrollViewDelegate {
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollVelocity = scrollView.panGestureRecognizer.velocity(in: nil)
        jump(scrollView)
    }
    
    fileprivate func jump(_ scrollView: UIScrollView) {
        
        if abs(scrollVelocity.y) > 800 {
            if scrollVelocity.y > 0 {
                let topOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
                scrollView.setContentOffset(topOffset, animated: true)
            }
            else {
                let bottomOffset = CGPoint(x: 0, y: baseActionsFrame.origin.y-baseActionsFrame.size.height+actionH)
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
            return
        }
        
        if qrCodeScale > 0.2 {
            let topOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
            scrollView.setContentOffset(topOffset, animated: true)
        }
        else {
            let bottomOffset = CGPoint(x: 0, y: baseActionsFrame.origin.y-baseActionsFrame.size.height+actionH)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        jump(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        jump(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if qrCodeBorder.frame == .zero {return}
        if baseQRCodeFrame == nil {
            baseQRCodeFrame = qrCodeBorder.frame
        }
        if baseActionsFrame == .zero {
            baseActionsFrame = actions.frame
        }
        qrCodeScale = (baseQRCodeFrame!.height-scrollView.contentOffset.y)/baseQRCodeFrame!.height
        qrCodeScale = qrCodeScale < 0 ? 0 : qrCodeScale
        qrContent.transform = CGAffineTransform.identity
        qrContent.transform = CGAffineTransform(scaleX: qrCodeScale, y: qrCodeScale)
            .concatenating(CGAffineTransform(translationX: 0, y: -scrollView.contentOffset.y/8))
        //qrContent.alpha = qrCodeScale
    }
}
