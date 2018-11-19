//
//  ContactView.swift
//  MileWallet
//
//  Created by denn on 31.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import SnapKit
import MileWalletKit

class ContactView: UIView {
    
    public var isEdited = false {
        didSet{
            pablicKeyLabelConstraint()
            iconView.alpha = isEdited ? 0.0 : 1.0
            publicKeyLabel.isUserInteractionEnabled = isEdited
            publicKeyLabel.placeholder = isEdited ? NSLocalizedString("Type or paste transfer address", comment: "") : ""
        }
    }
    
    public var avatar:Data? {
        didSet{
            guard let d = avatar else {
                iconView.image = nil
                litera.alpha = 1
                return
            }
            litera.alpha = 0
            iconView.image = UIImage(data: d)
            iconView.setNeedsDisplay()
        }
    }
    
    public var publicKey:String? {
        set{
            publicKeyLabel.text = newValue
        }
        get {
            return publicKeyLabel.text
        }
    }
    
    public var name:String? = "" {
        didSet{
            if let str = name, str.count > 0 {
                litera.text = String(str.prefix(1))
            }
            nameLabel.text = name
        }
    }
    
    fileprivate var nameLabel = UILabel()
    
    private lazy var publicKeyLabel:UITextField = {
        let t = UITextField.nameField(placeholder: "")
        t.font = Config.Fonts.address
        t.adjustsFontSizeToFitWidth = true
        t.isUserInteractionEnabled = false
        t.clearButtonMode = .whileEditing
        return t
    }()
    
    fileprivate let iconView = UIImageView()
    fileprivate var litera = UILabel()
    
    fileprivate var publicKeyLeft:ConstraintMakerExtendable!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLabel)
        addSubview(publicKeyLabel)
        addSubview(iconView)
        
        iconView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.centerY.equalToSuperview()
            m.height.equalTo(60)
            m.width.equalTo(iconView.snp.height)
        }
        
        nameLabel.textAlignment = .left
        nameLabel.font = Config.Fonts.caption
        nameLabel.textColor = UIColor.black
        nameLabel.backgroundColor = UIColor.clear
        
        publicKeyLabel.textAlignment = .left
        publicKeyLabel.font = Config.Fonts.contacts
        publicKeyLabel.textColor = UIColor.black
        publicKeyLabel.backgroundColor = UIColor.clear
        
        nameLabel.snp.makeConstraints { (m) in
            m.left.equalTo(iconView.snp.right).offset(10)
            m.top.equalToSuperview().offset(5)
            m.bottom.equalTo(self.snp.centerY)
            m.right.equalToSuperview().offset(-10)
        }
        
        pablicKeyLabelConstraint()
        
        litera.textAlignment = .center
        litera.font = Config.Fonts.header
        litera.textColor = UIColor.white
        litera.backgroundColor = UIColor.clear
        
        iconView.addSubview(litera)
        litera.snp.makeConstraints { (m) in
            m.center.equalTo(iconView)
            m.width.equalTo(iconView)
            m.height.equalTo(litera.snp.width)
        }
        
        iconView.backgroundColor = UIColor(hex: 0xD5E9F5)
        //iconView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        iconView.layer.cornerRadius = iconView.frame.size.width  / 2
        iconView.layer.masksToBounds = true
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFill
    }
    
    private func pablicKeyLabelConstraint() {
        publicKeyLabel.snp.remakeConstraints { (m) in
            if !isEdited {
                m.left.equalTo(iconView.snp.right).offset(10)
            }
            else {
                m.left.equalToSuperview().offset(20)
            }
            m.top.equalTo(nameLabel.snp.centerY).offset(5)
            m.bottom.equalTo(self).offset(5)
            m.right.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.layer.cornerRadius = iconView.frame.size.width  / 2
        iconView.layer.masksToBounds = true
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFill
        if avatar == nil {
            litera.alpha = 1
        }
        else {
            litera.alpha = 0
        }
    }
}

class ConactCell: UITableViewCell {
    
    var avatar:Data? {
        set{ contactView.avatar = newValue}
        get{ return contactView.avatar }
    }
    
    var publicKey:String?  {
        set{ contactView.publicKey = newValue}
        get{ return contactView.publicKey }
    }
    
    var name:String? {
        set{ contactView.name = newValue}
        get{ return contactView.name }
    }
    
    fileprivate let contactView = ContactView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(contactView)
        contactView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        
        add(border: .bottom,
                             color: Config.Colors.bottomLine,
                             width: 1,
                             padding: UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 0)
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setNeedsDisplay() {
        contactView.setNeedsDisplay()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let c = contactView.iconView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        backgroundColor = UIColor.clear
        contactView.iconView.backgroundColor = c
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let c = contactView.iconView.backgroundColor
        super.setSelected(selected, animated: animated)
        contactView.iconView.backgroundColor = c
    }
}

