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
