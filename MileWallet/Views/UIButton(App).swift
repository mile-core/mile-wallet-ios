//
//  UIButton(App).swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

extension UIButton {
    @objc public var substituteFont : UIFont? {
        get {
            return titleLabel?.font
        }
        set {
            titleLabel?.font = newValue
        }
    }
}

class AppButton: UIButton {
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = super.titleRect(forContentRect: contentRect)
        let imageRect = super.imageRect(forContentRect: contentRect)
        
        return CGRect(x: 0,
                      y: contentRect.height - (contentRect.height - padding - imageRect.size.height - titleRect.size.height) / 2 - titleRect.size.height,
                      width: contentRect.width,
                      height: titleRect.height)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageRect = super.imageRect(forContentRect: contentRect) //contentRect //super.imageRect(forContentRect: contentRect)
        let titleRect = self.titleRect(forContentRect: contentRect)
        
        return CGRect(x: contentRect.width/2.0 - imageRect.width/2.0,
                      y: (contentRect.height - padding - imageRect.size.height - titleRect.size.height) / 2,
                      width: imageRect.width,
                      height: imageRect.height)
    }
    
    private let padding: CGFloat
    
    init(padding: CGFloat) {
        self.padding = padding
        
        super.init(frame: .zero)
        self.titleLabel?.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

extension UIButton {
    
    static func app(padding: CGFloat = 16) -> UIButton {
        return AppButton(padding: padding)
    }
}
