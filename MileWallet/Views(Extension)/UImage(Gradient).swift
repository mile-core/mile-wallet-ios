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

