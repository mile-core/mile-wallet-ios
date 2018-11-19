//
//  WalletTableCell.swift
//  MileWallet
//
//  Created by denn on 20.09.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import SnapKit
import MileWalletKit

public class WalletTableCell: UITableViewCell {
    
    public var wallet:WalletContainer? {
        didSet{
            name.text = wallet?.wallet?.name
            let c = UIColor(hex: wallet?.attributes?.color ?? UIColor.black.hex)
            if reuseIdentifier == "sortCell"{
                self.backgroundColor = c
            }
            else {
                containerView.backgroundColor = Config.Colors.archivedCell.mix(infusion: c, alpha: 0.03)
            }
            startActivities()
        }
    }
    
    public var xdrValue:Float = 0 {
        didSet{
            xdrAmountLabel.text = Asset.xdr.stringValue(xdrValue)
        }
    }
    
    public var mileValue:Float = 0 {
        didSet{
            mileAmountLabel.text = Asset.mile.stringValue(mileValue)
        }
    }
    
    private var containerView = UIView()
    private var name:UILabel = UILabel()
    
    private var xdrLabel:UILabel = UILabel()
    private var mileLabel:UILabel = UILabel()
    
    private var xdrAmountLabel:UILabel = UILabel()
    private var mileAmountLabel:UILabel = UILabel()
    
    private func activityLoader(place:UIView)  -> UIActivityIndicatorView {
        let a = UIActivityIndicatorView(style: .white)
        a.hidesWhenStopped = true
        place.addSubview(a)
        a.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return a
    }
    
    public func startActivities()  {
        for a in activities { a.startAnimating() }
    }
    
    public func stopActivities()  {
        for a in activities { a.stopAnimating() }
    }
    
    private lazy var activities:[UIActivityIndicatorView] = [self.activityLoader(place: self.xdrAmountLabel),
                                                             self.activityLoader(place: self.mileAmountLabel)]

//    private let bg = UIImageView(image: Config.Images.basePattern)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
//        addSubview(bg)
//
//        bg.contentMode = .scaleAspectFill
//        bg.snp.makeConstraints { (m) in
//            m.edges.equalTo(self.snp.edges)
//        }
        
        xdrLabel.text = Asset.xdr.name
        mileLabel.text = Asset.mile.name
        
        containerView.layer.cornerRadius = Config.buttonRadius
        containerView.layer.masksToBounds = true
        containerView.clipsToBounds = true
        
        containerView.backgroundColor = Config.Colors.archivedCell
        contentView.addSubview(containerView)
        contentView.addSubview(name)
        containerView.addSubview(xdrLabel)
        containerView.addSubview(mileLabel)
        containerView.addSubview(xdrAmountLabel)
        containerView.addSubview(mileAmountLabel)
        
        name.textAlignment = .left
        name.numberOfLines = 3
        if reuseIdentifier == "sortCell" {
            name.textColor = .white
            name.font = Config.Fonts.title
        }
        else {
            name.textColor = .black
            name.font = Config.Fonts.name
        }
        
        xdrLabel.textColor = .white
        mileLabel.textColor = .white
        
        xdrAmountLabel.textAlignment = .left
        xdrAmountLabel.textColor = .white
        xdrAmountLabel.font = reuseIdentifier == "sortCell" ?  Config.Fonts.amount : Config.Fonts.caption
        xdrAmountLabel.minimumScaleFactor = 0.5
        xdrAmountLabel.adjustsFontSizeToFitWidth = true
        
        mileAmountLabel.textAlignment = .left
        mileAmountLabel.textColor = .white
        mileAmountLabel.font =  xdrAmountLabel.font
        mileAmountLabel.minimumScaleFactor = 0.5
        mileAmountLabel.adjustsFontSizeToFitWidth = true
        
        name.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(25)
            m.top.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }
        
        containerView.snp.makeConstraints { (m) in
            if reuseIdentifier == "sortCell" {
                m.top.equalTo(name.snp.bottom).offset(0)
            }
            else {
                m.top.equalTo(name.snp.bottom).offset(6)
            }
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.height.equalTo(60)
        }
        
        xdrLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(18)
            m.bottom.equalToSuperview()
            if reuseIdentifier == "sortCell" {
                m.width.equalTo(1)
                xdrLabel.alpha = 0
            }
            else {
                m.width.equalTo(40)
            }
        }
        
        mileLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalTo(containerView.snp.centerX)
            m.bottom.equalToSuperview()
            if reuseIdentifier == "sortCell" {
                m.width.equalTo(1)
                mileLabel.alpha = 0
            }
            else {
                m.width.equalTo(40)
            }
        }
        
        xdrAmountLabel.snp.makeConstraints { (m) in
            if reuseIdentifier == "sortCell" {
                m.left.equalToSuperview().offset(18)
            }
            else {
                m.left.equalTo(xdrLabel.snp.right).offset(10)
            }
            m.top.equalTo(xdrLabel)
            m.bottom.equalTo(xdrLabel)
            m.right.equalTo(containerView.snp.centerX).offset(-20)
        }
        
        mileAmountLabel.snp.makeConstraints { (m) in
            if reuseIdentifier == "sortCell" {
                m.left.equalTo(containerView.snp.centerX)
            }
            else {
                m.left.equalTo(mileLabel.snp.right).offset(10)
            }
            m.top.equalTo(mileLabel)
            m.bottom.equalTo(mileLabel)
            m.right.equalToSuperview().offset(-20)
        }
        
        if reuseIdentifier == "sortCell" {
            containerView.backgroundColor = .clear
            add(border: .bottom,
                color: Config.Colors.bottomLine,
                width: 1,
                padding: UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0))
        }
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
