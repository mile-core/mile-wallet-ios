//
//  UIColor(Hex).swift
//  MileWallet
//
//  Created by denn on 25.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

public extension UIColor{
    convenience init(hex: UInt, alpha: CGFloat=1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    public var hex:UInt {
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 1
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let redInt = UInt(red * 255 + 0.5)
            let greenInt = UInt(green * 255 + 0.5)
            let blueInt = UInt(blue * 255 + 0.5)
            
            return (redInt << 16) | (greenInt << 8) | blueInt;
        }
        return 0;
    }
}

extension UIColor
{
    func mix(infusion:UIColor, alpha:CGFloat) -> UIColor {
        let alpha2 = min(1.0, max(0, alpha))
        let beta = 1.0 - alpha2
        
        var r1:CGFloat = 0, r2:CGFloat = 0
        var g1:CGFloat = 0, g2:CGFloat = 0
        var b1:CGFloat = 0, b2:CGFloat = 0
        var a1:CGFloat = 0, a2:CGFloat = 0
        if getRed(&r1, green: &g1, blue: &b1, alpha: &a1) &&
            infusion.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        {
            let red     = r1 * beta + r2 * alpha2;
            let green   = g1 * beta + g2 * alpha2;
            let blue    = b1 * beta + b2 * alpha2;
            let alpha   = a1 * beta + a2 * alpha2;
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        // epique de las failuree
        return self
    }
}

