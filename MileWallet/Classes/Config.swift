//
//  Config.swift
//  MileWallet
//
//  Created by denis svinarchuk on 21.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import MileWalletKit

extension Config {
    public static let walletService = "karma.red.milek.wallet"    
    public static var isWalletKeychainSynchronizable = false
    
    public struct Colors {
        public static let background = UIColor.white
        public static let buttonBackground = UIColor.white
    }
}

