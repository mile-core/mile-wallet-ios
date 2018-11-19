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
    
    convenience init(title: String?=nil, image:UIImage?, action: ((_ sender:UIButton)->Void)?) {
        self.init()
        handler = action
        setImage(image, for: .normal)
        setTitle(title, for: .normal)
        imageView?.contentMode = .scaleAspectFit
        titleLabel?.font = Config.Fonts.toolBar
        addTarget(self, action:#selector(self.__0actionHandler(sender:)), for: .touchUpInside)
    }
    
    @objc fileprivate func __0actionHandler(sender:UIButton){
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
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        imageView?.contentMode = .scaleAspectFill
        imageView?.layer.cornerRadius = (imageView?.frame.size.width ?? 0 )  / 2
        imageView?.layer.masksToBounds = true
        imageView?.clipsToBounds = true
    }
}

class TollBarButton: Button {
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = super.titleRect(forContentRect: contentRect)
        let imageRect = super.imageRect(forContentRect: contentRect)
        
        return CGRect(x: 0,
                      y: contentRect.height - (contentRect.height - padding - imageRect.size.height - titleRect.size.height) / 2 - titleRect.size.height,
                      width: contentRect.width,
                      height: titleRect.height)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageRect = super.imageRect(forContentRect: contentRect)
        let titleRect = self.titleRect(forContentRect: contentRect)
        
        return CGRect(x: contentRect.width/2.0 - imageRect.width/2.0,
                      y: (contentRect.height - padding - imageRect.size.height - titleRect.size.height) / 2,
                      width: imageRect.width,
                      height: imageRect.height)
    }
    
    private var padding: CGFloat
    
    convenience init(title: String?=nil, image:UIImage?, padding:CGFloat = 12, action: ((_ sender:UIButton)->Void)?) {
        self.init(padding: padding)
        self.titleLabel?.textAlignment = .center
        handler = action
        setImage(image, for: .normal)
        setTitle(title, for: .normal)
        imageView?.contentMode = .scaleAspectFit
        titleLabel?.font = Config.Fonts.toolBar
        addTarget(self, action:#selector(self.__0actionHandler(sender:)), for: .touchUpInside)
    }
        
    init(padding: CGFloat) {
        self.padding = padding
        super.init(frame: .zero)
        self.titleLabel?.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
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
    
    init(padding:CGFloat = 0.05, style: Style = .vertical) {
        self.padding = padding

        super.init(frame: .zero)
        switch style {
        case .vertical:
            setImage(UIImage(named: "icon-vertical-separator"), for: UIControl.State.normal)
        default:
            break
        }
        imageView?.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private var padding: CGFloat
}

extension UIButton {
    
    static func toolBarButton(padding: CGFloat = 12) -> UIButton {
        let app = TollBarButton(padding: padding)
        app.titleLabel?.font =  Config.Fonts.button
        app.imageView?.contentMode = .scaleAspectFit
        app.titleLabel?.adjustsFontSizeToFitWidth = true
        return app
    }
    
    static func toolBarButton(padding: CGFloat = 12, image: UIImage?, title:String?, target:Any?, action:Selector) -> UIButton {
        let app = TollBarButton(padding: padding)
        app.titleLabel?.font =  Config.Fonts.button
        app.imageView?.contentMode = .scaleAspectFit
        app.titleLabel?.adjustsFontSizeToFitWidth = true
        
        app.setImage(image, for: UIControl.State.normal)
        app.setTitle(title, for: .normal)
        app.addTarget(target, action:action, for: UIControl.Event.touchUpInside)

        return app
    }
}
