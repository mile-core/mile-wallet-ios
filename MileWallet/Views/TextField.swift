//
//  TextField.swift
//  MileWallet
//
//  Created by denis svinarchuk on 03.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

extension UITextField {    
    
    public static func decimalsField() -> UITextField {
        let text = UITextField()
        text.isUserInteractionEnabled = true
        text.contentMode = .center
        text.textAlignment = .left
        text.keyboardType = .decimalPad
        text.layer.borderWidth = 0
        text.clearsOnInsertion = true
        text.clearButtonMode = .always
        text.font = Config.Fonts.edit
        text.textColor = Config.Colors.edit
        return text
    } 
    
    public static func hexField() -> UITextField {
        let text = UITextField()
        text.isUserInteractionEnabled = true
        text.contentMode = .center
        text.textAlignment = .left
        text.layer.borderWidth = 0
        text.clearButtonMode = .always
        text.font = Config.Fonts.edit
        text.textColor = Config.Colors.edit
        return text
    }     

    public static func nameField(placeholder:String = "") -> UITextField {
        let text = UITextField()
        text.isUserInteractionEnabled = true
        text.contentMode = .center
        text.textAlignment = .left
        text.layer.borderWidth = 0
        text.clearButtonMode = .always
        text.placeholder = placeholder
        text.borderStyle = .none
        text.font = Config.Fonts.edit
        text.textColor = Config.Colors.edit
        return text
    }         
}

extension UITextView {
    
    public static func hexField() -> UITextView {
        let text = UITextView()
        text.isUserInteractionEnabled = true
        text.textAlignment = .left
        text.textContainer.lineBreakMode = .byWordWrapping
        text.textContainer.maximumNumberOfLines = 4
        text.isSelectable = true
        text.isScrollEnabled = false
        text.layer.borderWidth = 0.5
        text.font = UIFont.systemFont(ofSize: 14)
        text.clearsOnInsertion = true        
        return text
    }    
}
