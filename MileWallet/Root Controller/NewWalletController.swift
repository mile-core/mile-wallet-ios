//
//  NewWalletController.swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit
import ObjectMapper

class NewWalletController: NavigationController {
    let contentController = NewWalletControllerImp()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Config.Colors.background
        setViewControllers([contentController], animated: true)
    }
}

class NewWalletControllerImp: Controller {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("New wallet", comment: "")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closePayments(sender:)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(addWalletHandler(_:)))
        
        contentView.addSubview(name)
        contentView.addSubview(line)
        contentView.addSubview(colorLabel)
        contentView.addSubview(pickerView)
        
        name.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.topMargin).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(60)
        }
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(name.snp.bottomMargin).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }
        
        colorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
        pickerView.snp.makeConstraints { (m) in
            m.top.equalTo(colorLabel.snp.bottom).offset(0)
            m.left.equalToSuperview().offset(0)
            m.right.equalToSuperview().offset(0)
            m.height.equalTo(80)
        }
        
        pickerView.cellSpacing = 20
        
        if let index = Config.Colors.palette.index(where: { (c) -> Bool in
            if c === Config.Colors.defaultColor {
                return true
            }
            return false
        }) {
            pickerView.selectCellAtIndex(index)
        }        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc private func closePayments(sender:Any){
        dismiss(animated: true)
    }
    
    @objc private func addWalletHandler(_ sender: UIButton) {
        addWallet()
    }
    
    private lazy var pickerView: ColorPicker = {
        let v = ColorPicker(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 60))
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    private let line:UIView = {
        let l = UIView()
        l.backgroundColor = Config.Colors.separator
        return l
    }()
    
    private let colorLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.text = NSLocalizedString("Wallet color", comment: "")
        l.textColor = Config.Colors.caption
        l.font = Config.Fonts.caption
        return l
    }()
    
    private let name: UITextField = {
        let t = UITextField.nameField(placeholder: NSLocalizedString("Wallet name", comment: ""))
        return t
    }()
    
    fileprivate var currentColor = Config.Colors.defaultColor
    fileprivate var currentWallet:Wallet?    
    
    fileprivate lazy var attentionCover:UIView = {
        let v = UIView()
        let image = UIImageView(image: Config.Images.basePattern)
        image.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        image.frame = v.bounds
        image.contentMode = .scaleAspectFill
        v.addSubview(image)
        v.backgroundColor = self.currentColor

        let printerIcon = UIImageView(image: Config.Images.printerIcon)
        v.addSubview(printerIcon)
        printerIcon.snp.makeConstraints({ (m) in
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
            
            m.top.equalTo(printerIcon.snp.bottom).offset(40)
            m.width.equalToSuperview()
        })

        let back = UIButton(type: .custom)
        back.setTitle(NSLocalizedString("Back to main screen", comment: ""), for: UIControlState.normal)
        back.setTitleColor(Config.Colors.back, for: .normal)
        back.titleLabel?.font = Config.Fonts.caption
        back.backgroundColor = UIColor.white
        back.layer.cornerRadius = Config.buttonRadius
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
        textContainer.layer.cornerRadius = Config.buttonRadius
        textContainer.clipsToBounds = true

        v.addSubview(textContainer)

        textContainer.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalTo(back.snp.top).offset(-18)
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
    
    fileprivate lazy var printControllerBg:UIImageView = {
        let v = UIImageView(image: Config.Images.basePattern)
        v.alpha = 0
        return v
    }()
}

extension NewWalletControllerImp: UIPrintInteractionControllerDelegate {
    
    func printInteractionControllerParentViewController(_ printInteractionController: UIPrintInteractionController) -> UIViewController? {
        return self.navigationController?.topViewController
    }
    
    func printInteractionControllerWillPresentPrinterOptions(_ printInteractionController: UIPrintInteractionController) {
        UIApplication.shared.keyWindow?.addSubview(printControllerBg)
        printControllerBg.snp.makeConstraints { (m) in
            m.edges.equalToSuperview().inset(UIEdgeInsets(top: -200, left: 0, bottom: 0, right: 0))
        }
        printControllerBg.backgroundColor = currentColor
        UIView.animate(withDuration: Config.animationDuration) {
            self.printControllerBg.alpha = 1
        }
    }
    
    func printInteractionControllerDidDismissPrinterOptions(_ printInteractionController: UIPrintInteractionController) {
        UIView.animate(withDuration: Config.animationDuration, animations: {
            self.printControllerBg.alpha = 0
        }) { (flag) in
            self.printControllerBg.removeFromSuperview()
        }
    }
}

extension NewWalletControllerImp {
    
    
    @objc fileprivate func backMainHandler(sender:UIButton){
        coverDown()
        self.dismiss(animated: true)
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
    
    private func coverDown() {
        UIView.animate(withDuration: Config.animationDuration, animations: {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.attentionCover.alpha = 0
        }, completion: { (flag) in
            self.attentionCover.removeFromSuperview()
        })
    }
    
    private func coverUp()  {
        name.resignFirstResponder()
        attentionCover.alpha = 0
        attentionCover.backgroundColor = self.currentColor
        attentionCover.frame = UIScreen.main.bounds
        UIApplication.shared.keyWindow?.addSubview(attentionCover)
        attentionCover.snp.makeConstraints { (m) in
            m.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
       
        UIView.animate(withDuration: Config.animationDuration,
                       animations: {
                        self.attentionCover.alpha = 1
        }) { (flag) in
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.attentionCover.removeFromSuperview()
            self.view.addSubview(self.attentionCover)
            self.attentionCover.snp.makeConstraints { (m) in
                m.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
        }
    }
    
    fileprivate func addWallet()  {
        
        let closeString = NSLocalizedString("Close", comment: "")
        
        guard let name = name.text else { return }
        
        guard !name.isEmpty else { return }
        
        let checkWallet = WalletStore.shared.wallet(by: name)
        
        if checkWallet != nil {
            UIAlertController(title: NSLocalizedString("Wallet Error", comment: ""),
                              message:  NSLocalizedString("Wallet with the same name already exists", comment: ""),
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel)
                .present(by: self)
            return
        }
        
        loaderStart()
        
        func close() {
            self.loaderStop()
            self.dismiss(animated: true, completion: nil)
        }
        
        Wallet.create(name: name, secretPhrase: nil, error: { error in
            
            UIAlertController(title: NSLocalizedString("Wallet Error", comment: ""),
                              message:  error?.description,
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel)
                .present(by: self)
            
        }) { (wallet) in
            
            self.currentWallet = wallet
            
            do {
                guard let json = Mapper<Wallet>().toJSONString(wallet) else {
                    UIAlertController(title: nil,
                                      message:  NSLocalizedString("Wallet could not be created from the secret phrase", comment: ""),
                                      preferredStyle: .alert)
                        .addAction(title: "Close", style: .cancel, handler: { (action) in
                            close()
                        })
                        .present(by: self)
                    return
                }
                
                try WalletStore.shared.keychain.set(json, key: name)

                let walletAttr = WalletAttributes(color: self.currentColor.hex,
                                                  isActive:true)

                guard let attr = Mapper<WalletAttributes>().toJSONString(walletAttr) else {
                    self.loaderStop()
                    self.dismiss(animated: true, completion: nil)
                    close()
                    return
                }

                try WalletStore.shared.keychain.setWalletAttr(attr, key: name)
                
                self.loaderStop()
                
                self.coverUp()
                
            }
            catch let error {
                
                UIAlertController(title: nil,
                                  message:  error.description,
                                  preferredStyle: .alert)
                    .addAction(title: closeString, style: .cancel, handler: { (action) in
                        close()
                    })
                    .present(by: self)
            }
        }
    }
}

extension NewWalletControllerImp: ColorPickerDataSource {
    func colorPickerColors() -> [UIColor] {
        return Config.Colors.palette
    }
}

extension NewWalletControllerImp: ColorPickerDelegate {
    
    func colorPicker(_ colorPickerView: ColorPicker, didSelectCell cell: ColorPickerCell) {
        cell.layer.contents = Config.Images.colorPickerOn.cgImage
        cell.layer.contentsScale = 4
        cell.layer.contentsGravity = kCAGravityCenter
        cell.layer.isGeometryFlipped = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.16
        cell.layer.shadowOffset = CGSize(width: 0, height: -3)
        cell.layer.shadowRadius = 3
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.masksToBounds = false
    }
    
    func colorPicker(_ colorPickerView: ColorPicker, didSelectIndex at: Int, color: UIColor) {
        (navigationController as? NavigationController)?.titleColor = color
        currentColor = color
    }
    
    func sizeForCellAtIndex(_ colorPickerView: ColorPicker, index at: Int) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}
