//
//  UIView(Gradient).swift
//  MileWallet
//
//  Created by denn on 23.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

public extension UIImage {
    static func gradient(colors: [UIColor], with frame: CGRect) -> UIImage? {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.colors = colors.map{ $0.cgColor } 
        UIGraphicsBeginImageContext(CGSize(width: frame.width, height: frame.height))
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIColor{
    convenience init(hex: UInt, alpha: CGFloat=1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
