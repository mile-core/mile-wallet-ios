//
//  UIView(Border).swift
//  MileWallet
//
//  Created by denn on 28.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

import UIKit

enum ViewBorder: String {
    case left, right, top, bottom
}

extension UIView {
    
    //private static let __tag = UUID().hashValue
    
    func add(border: ViewBorder, color: UIColor, width: CGFloat, padding: UIEdgeInsets) {
        let borderLayer = UIView()
        
        borderLayer.backgroundColor = color
        borderLayer.layer.name = border.rawValue
        borderLayer.tag = border.hashValue
        
        addSubview(borderLayer)
        switch border {
        case .left:
            borderLayer.snp.makeConstraints { (m) in
                m.left.equalToSuperview().offset(0)
                m.width.equalTo(width)
                m.bottom.equalToSuperview().offset(-padding.bottom)
                m.top.equalToSuperview().offset(padding.top)
            }
        case .right:
            borderLayer.snp.makeConstraints { (m) in
                m.right.equalToSuperview().offset(-width)
                m.width.equalTo(width)
                m.bottom.equalToSuperview().offset(-padding.bottom)
                m.top.equalToSuperview().offset(padding.top)
            }
        case .top:
            borderLayer.snp.makeConstraints { (m) in
                m.left.equalToSuperview().offset(padding.left)
                m.right.equalToSuperview().offset(-padding.right)
                m.top.equalToSuperview()
                m.height.equalTo(width)
            }
        case .bottom:
            borderLayer.snp.makeConstraints { (m) in
                m.left.equalToSuperview().offset(padding.left)
                m.right.equalToSuperview().offset(-padding.right)
                m.bottom.equalToSuperview().offset(-width)
                m.height.equalTo(width)
            }
        }
    }
    
    func remove(border: ViewBorder) {
        var forRemove:UIView?
        for v in subviews {
            if v.tag == border.hashValue {
                forRemove = v
            }
        }
        if let layer = forRemove {
            layer.removeFromSuperview()
        }
    }
    
}
