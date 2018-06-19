//
//  HTML.swift
//  MileWallet
//
//  Created by denis svinarchuk on 14.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import EFQRCode
import MileWalletKit

class HTMLTemplate {
    
    /**
     Reads the given HTML file and replaces `{{address}}`, `{{private-key}}` and {{name}} with proper values.
     
     - parameters:
     - fileName: The name of the HTML file.
     
     - returns: The transformed HTML code.
     */
    class func get(wallet: Wallet) -> String {
        
        guard let htmlFile = Bundle.main.url(forResource: "PrintSecretTemplate", withExtension: "html")
            else { fatalError("Error locating HTML file.") }
        
        guard var htmlContent = try? String(contentsOf: htmlFile)
            else { fatalError("Error getting HTML file content.") }
        
        
        let items = ["address":     (wallet.publicKey,  wallet.publicKeyQRImage?.imageSrc), 
                     "private-key": (wallet.privateKey, wallet.privateKeyQRImage?.imageSrc), 
                     "notes":       (wallet.name,       wallet.nameQRImage?.imageSrc)]
        
        for k in items.keys {
            if let (what, src) = items[k] { 
                htmlContent = htmlContent.replacingOccurrences(of: "{{\(k)}}", 
                    with: what ?? "-")            
                htmlContent = htmlContent.replacingOccurrences(of: "{{\(k+"-qr")}}", with: src ?? "")
            }
        }
        
        return htmlContent
    }
    
    class func getAmount(wallet: Wallet, amount: String) -> String {
        
        guard let htmlFile = Bundle.main.url(forResource: "PrintPaymentTemplate", withExtension: "html")
            else { fatalError("Error locating HTML file.") }
        
        guard var htmlContent = try? String(contentsOf: htmlFile)
            else { fatalError("Error getting HTML file content.") }
        
        let data = wallet.amountQRImage(amount)  
        
        let items = ["address": (wallet.publicKey ?? "",  ""), 
                     "amount":  (amount,                  ""), 
                     "notes":   (wallet.name ?? "",       ""),
                     "payment": (amount, data?.imageSrc ?? "")]
        
        for k in items.keys {
            if let (what, src) = items[k] { 
                htmlContent = htmlContent.replacingOccurrences(of: "{{\(k)}}", 
                    with: what)            
                htmlContent = htmlContent.replacingOccurrences(of: "{{\(k+"-qr")}}", with: src)
            }
        }
        
        return htmlContent
    }
}


