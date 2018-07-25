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
            print("index = Config.Colors.palette.index == \(index)")
            pickerView.selectCellAtIndex(index)
        }

    }
        
    @objc private func closePayments(sender:Any){
        dismiss(animated: true)
    }
    
    @objc private func addWalletHandler(_ sender: UIButton) {
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
    
    private let name: UITextField = {
        let t = UITextField.nameField(placeholder: NSLocalizedString("Wallet name", comment: ""))
        return t
    }()
   
    private var currentColor = Config.Colors.defaultColor
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
    }
    
    func sizeForCellAtIndex(_ colorPickerView: ColorPicker, index at: Int) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}
