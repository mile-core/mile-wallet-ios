//
//  Config.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

struct Config {
    public static let mileHosts = ["https://wallet.mile.global", "http://localhost:4000", "https://mile-wallet.karma.red", "https://149.28.162.70:4000"]
    
    public static let walletService = "karma.red.milek.wallet"
    
    public static var isWalletKeychainSynchronizable = false
    
    public static let publicKeyQrPrefix    = "MILE:PUB:"
    public static let privateKeyQrPrefix   = "MILE:PRIV:"
    public static let noteQrPrefix         = "MILE:NOTE:"
    public static let nameQrPrefix         = "MILE:NOTE:NAME:"
    public static let secretPhraseQrPrefix = "MILE:SECRET:"
    public static let amountQrPrefix       = "MILE:AMOUNT:"
    public static let paymentQrPrefix      = "MILE:PAYMENT:"
    
    struct Colors {
        public static let background = UIColor.white
        public static let buttonBackground = UIColor.white
    }
    
}
