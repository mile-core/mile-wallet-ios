//
//  Store.swift
//  MileWallet
//
//  Created by denis svinarchuk on 02.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import KeychainAccess
import MileWalletKit

public class Store {
    public static let shared:Store = Store()
    public let keychain = Keychain(accessGroup: Config.walletService).synchronizable(Config.isWalletKeychainSynchronizable)    
    public var items:[[String : Any]] {
        return self.keychain.allItems()
    }    
    private init() {}
}
