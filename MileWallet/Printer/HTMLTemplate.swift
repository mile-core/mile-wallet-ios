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
    
    static let logo = (UIImage(named: "MileLogo")?.imageSrc)!
    static let pattern = (UIImage(named: "PagePattern")?.imageSrc)!

    class func secret(wallet: Wallet) -> String {
        
        guard let htmlFile = Bundle.main.url(forResource: "SecretTemplate", withExtension: "html")
            else { fatalError("Error locating HTML file.") }
        
        guard var htmlContent = try? String(contentsOf: htmlFile)
            else { fatalError("Error getting HTML file content.") }
        
        
        let pk = wallet.privateKey ?? "000000000000000000000000000000000000000000000000000000000000"
        let fk = pk[0..<48]
        let ek = pk[48..<pk.count]
        
        let items = [
            "private-key-string":     (fk + " " + ek, wallet.privateKeyQr?.imageSrc),
            "private-key": (wallet.privateKey, wallet.privateKeyQr?.imageSrc),
            "logo": (logo, ""),
            "pattern": (pattern, "")
        ]
        
        for k in items.keys {
            if let (what, src) = items[k] { 
                htmlContent = htmlContent.replacingOccurrences(of: "{{\(k)}}", 
                    with: what ?? "-")            
                htmlContent = htmlContent.replacingOccurrences(of: "{{\(k+"-qr")}}", with: src ?? "")
            }
        }
        
        return htmlContent
    }
    
    class func contact(wallet: Wallet) -> String {
        
        guard let htmlFile = Bundle.main.url(forResource: "PrintContactTemplate", withExtension: "html")
            else { fatalError("Error locating HTML file.") }
        
        guard var htmlContent = try? String(contentsOf: htmlFile)
            else { fatalError("Error getting HTML file content.") }
        
        
        let items = ["public-key": (wallet.publicKey,  wallet.publicKeyQr?.imageSrc),
                     "name":       (wallet.name,       wallet.nameQr?.imageSrc)]
                
        for k in items.keys {
            if let (what, src) = items[k] {
                htmlContent = htmlContent.replacingOccurrences(of: "{{\(k)}}",
                    with: what ?? "-")
                htmlContent = htmlContent.replacingOccurrences(of: "{{\(k+"-qr")}}", with: src ?? "")
            }
        }
        
        return htmlContent
    }
    
    class func invoice(wallet: Wallet, assets:String, amount: String) -> String {
        
        guard let htmlFile = Bundle.main.url(forResource: "InvoiceTemplate", withExtension: "html")
            else { fatalError("Error locating HTML file.") }
        
        guard var htmlContent = try? String(contentsOf: htmlFile)
            else { fatalError("Error getting HTML file content.") }
        
        let data = wallet.paymentQr(assets: assets, amount: amount)
        
        let pk = wallet.publicKey ?? "000000000000000000000000000000000000000000000"
        let fk = pk[0..<32]
        let ek = pk[32..<pk.count]
        
        let items = [
            "address": (fk + " " + ek,  ""),
            "amount":  (amount,                  ""),
            "assets":  (assets,       ""),
            "payment": (amount, data?.imageSrc ?? ""),
            "logo": (logo, ""),
            "pattern": (pattern, "")
        ]
        
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


