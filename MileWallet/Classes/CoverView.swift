//
//  CoverView.swift
//  MileWallet
//
//  Created by denis svinarchuk on 28.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

extension UIView {
    
    private static let coverView:UIImageView = {
        let v = UIImageView(image: UIImage(named: "logo-fill-blue"))
        v.contentMode = .center
        v.backgroundColor = UIColor(red: 41/255, green: 59/255, blue: 143/255, alpha: 1)        
        v.frame = UIScreen.main.bounds
        v.alpha = 0
        return v
    }()
    
    static func cover() {
        if let window = UIApplication.shared.keyWindow {            
            coverView.frame = UIScreen.main.bounds
            coverView.alpha = 1
            window.addSubview(coverView)
        }
    }
    
    static func uncover(complete:(()->Void)?=nil) {
        guard let complete = complete else {
            coverView.removeFromSuperview()      
            return
        }
        UIView.animate(withDuration: 0.2, animations: { 
            coverView.alpha = 0
        }) { (flag) in
            coverView.removeFromSuperview()
            complete()
        }
    }
}
