//
//  Utils.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import EFQRCode

public extension String {
    static let numberFormatter = NumberFormatter()
    var floatValue: Float {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.floatValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.floatValue
            }
        }
        return 0
    }
}

public func groupBy<C: Collection, K: Hashable>(_ xs: C, key: (C.Iterator.Element) -> K) -> [K:[C.Iterator.Element]] {
    var gs: [K:[C.Iterator.Element]] = [:]
    for x in xs {
        let k = key(x)
        var ys = gs[k] ?? []
        ys.append(x)
        gs.updateValue(ys, forKey: k)
    }
    return gs
}

extension UIImage {
    
    public var base64:String? {
        return UIImagePNGRepresentation(self)?.base64EncodedString() 
    }

    public var imageSrc:String {
        if let b = base64 { 
            return "data:image/png;base64,\(b)"
        }
        return ""
    }
    
    public static func qrCode(for content: String) -> UIImage? {
        if let tryImage = EFQRCode.generate(content: content) {
            return UIImage(cgImage: tryImage, scale: 1, orientation: UIImageOrientation.up)
        } 
        return nil
    }        
}

extension String {
    
    public var qrCodeImage:UIImage? {
        return UIImage.qrCode(for: self)
    }
    
    public var qrCodeImageSrc: String {
        return UIImage.qrCode(for: self)?.imageSrc ?? ""
    }
    
    public func qrCodeImage(with prefix:String) -> UIImage? {
        return UIImage.qrCode(for: prefix+self)
    }
    
    public func qrCodeImageSrc(with prefix:String) -> String {
        return self.qrCodeImage(with: prefix)?.imageSrc ?? ""
    }
}

extension UIAlertController {
    
    @discardableResult
    func addAction(title: String?, style: UIAlertActionStyle = .default, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        addAction(UIAlertAction(title: title, style: style, handler: handler))
        return self
    }
    
    func present(by viewController: UIViewController) {
        viewController.present(self, animated: true)
    }
}

extension UIPrintInteractionController{
    
}
