//
//  UIButton(App).swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

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

class Button: UIButton {
    fileprivate var handler:((_ sender:UIButton)->Void)?
    
    convenience init(image:UIImage?, action: ((_ sender:UIButton)->Void)?) {
        self.init()
        handler = action
        setImage(image, for: UIControlState.normal)
        imageView?.contentMode = .scaleAspectFit
        titleLabel?.font = Config.Fonts.toolBar
        addTarget(self, action:#selector(self.__actionHandler(sender:)), for: UIControlEvents.touchUpInside)
    }
    
    @objc private func __actionHandler(sender:UIButton){
        (sender as? Button)?.handler?(sender)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RoundButton: Button {
    
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
        imageView?.contentMode = .scaleAspectFill
        imageView?.layer.cornerRadius = (imageView?.frame.size.width ?? 0 )  / 2
        imageView?.layer.masksToBounds = true
        imageView?.clipsToBounds = true
    }
}

class AppButton: Button {
    
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

class ToolButton: Button {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerTextAndImage()
    }
    
    func centerTextAndImage() {
        let size = bounds.size
        let insetAmount = -size.width/2/2
        let titleRect = self.titleRect(forContentRect: bounds)
        let offset = titleRect.size.height/2
        imageEdgeInsets = UIEdgeInsets(top: -offset, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: size.height+offset, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
}

class Separator: UIButton {
    
    enum Style {
        case vertical
        case horizontal
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageRect = super.imageRect(forContentRect: contentRect)
        
        return CGRect(x: imageRect.origin.x, y: imageRect.origin.y+imageRect.size.height*padding, width: imageRect.size.width, height: imageRect.size.height-imageRect.size.height*padding*2)
    }
    
    init(padding:CGFloat = 0.1, style: Style = .vertical) {
        self.padding = padding

        super.init(frame: .zero)
        switch style {
        case .vertical:
            setImage(UIImage(named: "icon-vertical-separator"), for: UIControlState.normal)
        default:
            break
        }
        imageView?.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private var padding: CGFloat
}

extension UIButton {
    
    static func app(padding: CGFloat = 16) -> UIButton {
        let app = AppButton(padding: padding)
        app.titleLabel?.font =  Config.Fonts.button
        return app
    }
    
    static func toolBar(title: String?, image: UIImage?, handler: ((_ sender:UIButton)->Void)?=nil) -> UIBarButtonItem {
        let app = ToolButton()
        app.handler = handler

        app.setImage(image, for: UIControlState.normal)
        app.imageView?.contentMode = .scaleAspectFit
        app.setTitle(title, for: .normal)
        app.titleLabel?.font = Config.Fonts.toolBar
        app.addTarget(self, action:#selector(UIButton.actionHandler(sender:)), for: UIControlEvents.touchUpInside)
        
        let item = UIBarButtonItem(customView: app)
        
// WTF!??
//
//        let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.done, target: self, action:#selector(UIButton.actionHandler(sender:)))
//        item.title = title
//        item.tintColor = UIColor.black
//        item.image = image
        
        return item
    }
    
     @objc static private func actionHandler(sender:UIButton){
        (sender as? Button)?.handler?(sender)
    }
}
