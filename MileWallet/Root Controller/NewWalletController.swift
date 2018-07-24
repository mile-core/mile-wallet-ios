//
//  NewWalletController.swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

class NewWalletController: NavigationController {
    let contentController = NewWalletControllerImp()
    override func viewDidLoad() {
        super.viewDidLoad()
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
            m.top.equalTo(colorLabel.snp.bottom).offset(10)
            m.left.equalToSuperview().offset(0)
            m.right.equalToSuperview().offset(0)
            m.height.equalTo(70)
        }
        
        pickerView.selectionColor = UIColor.black.withAlphaComponent(0.3)
        pickerView.selectedBorderWidth = 1.5
        pickerView.cellSpacing = 20

    }
    
    @objc func closePayments(sender:Any){
        dismiss(animated: true)
    }
    
    @objc func addWalletHandler(_ sender: UIButton) {
        //addWallet()
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
    
    let name: UITextField = {
        let t = UITextField.nameField(placeholder: NSLocalizedString("Wallet name", comment: ""))
        return t
    }()
   
}

extension NewWalletControllerImp: ColorPickerDataSource {
    
    private static let _colors:[UIColor] = [
        UIColor(hex: 0x9466FD),
        UIColor(hex: 0x6679FD),
        UIColor(hex: 0x66C3FD),
        UIColor(hex: 0x52CAE0),
        UIColor(hex: 0xADD4EE),
        UIColor(hex: 0xff8a80),
        UIColor(hex: 0x3949ab),
    ]
    
    func colors() -> [UIColor] {
        return NewWalletControllerImp._colors
    }
}

extension NewWalletControllerImp: ColorPickerDelegate {
    
    func didSelectColorAtIndex(_ colorPickerView: ColorPicker, index: Int, color: UIColor) {
        print("Index is ", index)
        //self.view.backgroundColor = color
        (navigationController as? NavigationController)?.titleColor = color
    }
    
    func sizeForCellAtIndex(_ colorPickerView: ColorPicker, index: Int) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}
