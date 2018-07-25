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
import ObjectMapper

public struct WalletContainer {
    public var wallet:Wallet?
    public var attributes:WalletAttributes?
}

public class WalletStore {
    public static let shared:WalletStore = WalletStore()
    
    public var keychain:Keychain {
        return Keychain(accessGroup: Config.walletService).synchronizable(Config.isWalletKeychainSynchronizable)        
    }    
    
    public var items:[[String : Any]] {
        return self.keychain.allItems()
    }
    
    public var wallets:[WalletContainer] {
        return items.compactMap({ (item) -> WalletContainer? in
            if let value =  item["value"] as? String{
                if let w = Wallet(JSONString: value) {
                    if w.publicKey == nil {
                        return nil
                    }
                    do {
                        if let json = try keychain.getWalletAttr(w.name!),
                            let a = WalletAttributes(JSONString: json) {
                            return WalletContainer(wallet: w, attributes: a)
                        }
                    }
                    catch {}
                    let a = WalletAttributes(color: Config.Colors.defaultColor.hex, isActive:true)
                    return WalletContainer(wallet: w,
                                           attributes: a)
                }
                return nil
            }
            return nil
        })
    }
    
    public var acitveWallets:[WalletContainer] {
        return wallets.compactMap({ (w) -> WalletContainer? in
            guard let a = w.attributes else { return nil}
            return a.isActive ? w : nil
        })
    }
    
    public var archivedWallets:[WalletContainer] {
        return wallets.compactMap({ (w) -> WalletContainer? in
            guard let a = w.attributes else { return nil}
            return a.isActive ? nil : w
        })
    }
    
    public func wallet(by name:String) -> WalletContainer? {
        do {
            guard let wjson = try keychain.get(name) else { return nil }
            
            guard let w = Wallet(JSONString: wjson) else { return nil }
            
            if let json = try keychain.getWalletAttr(name),
                let a = WalletAttributes(JSONString: json) {
                return WalletContainer(wallet: w, attributes: a)
            }
            let a = WalletAttributes(color: Config.Colors.defaultColor.hex, isActive:true)
            return WalletContainer(wallet: w,
                                   attributes: a)
        }
        catch {
            return nil
        }
    }
    
    private init() {}
}

public extension Keychain {
    public func setWalletAttr(_ value: String, key: String) throws {
        try set(value, key: key+"-wallet-attr")
    }
    public func getWalletAttr(_ key: String) throws -> String? {
        return try getString(key+"-wallet-attr")
    }
    
    public func removeWalletAttr(_ key: String) throws {
        try remove(key+"-wallet-attr")
    }
}

public struct WalletAttributes {
    var color:UInt = Config.Colors.defaultColor.hex
    var isActive:Bool = true
}

extension WalletAttributes: Mappable {
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        color     <- map["wallet_color"]
        isActive  <- map["is_active"]
    }
}

