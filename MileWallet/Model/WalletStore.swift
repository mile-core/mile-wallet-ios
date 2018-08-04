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
            
            if let value =  item["value"] as? String, let key = item["key"] as? String{
                if let w = Wallet(JSONString: value) {
                    
                    if let pk = w.publicKey {
                        if pk != key {
                            return nil
                        }
                    }
                    else {
                        return nil
                    }
                    do {
                        if let json = try keychain.getWalletAttr(w.publicKey!),
                            let a = WalletAttributes(JSONString: json) {
                            return WalletContainer(wallet: w, attributes: a)
                        }
                    }
                    catch {}
                    let a = WalletAttributes(
                        publicKey: key,
                        color: Config.Colors.defaultColor.hex,
                        isActive:true)
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
    
    public func wallet(by public_key:String) -> WalletContainer? {
        do {
            guard let wjson = try keychain.get(public_key) else { return nil }
            
            guard let w = Wallet(JSONString: wjson) else { return nil }
            
            if let json = try keychain.getWalletAttr(public_key),
                let a = WalletAttributes(JSONString: json) {
                return WalletContainer(wallet: w, attributes: a)
            }
            let a = WalletAttributes(
                publicKey: public_key,
                color: Config.Colors.defaultColor.hex, isActive:true)
            return WalletContainer(wallet: w,
                                   attributes: a)
        }
        catch {
            return nil
        }
    }
    
    public func find(name:String) -> WalletContainer? {
        do {
            
            let it = items
            guard let index = (it.index { (item) -> Bool in
                if let json  = item["value"] as? String, let n = Wallet(JSONString: json)?.name {
                    return name == n
                }
                return false
            }) else {
                return nil
            }
            
            guard let wjson = it[index]["value"] as? String else { return nil }
            
            guard let w = Wallet(JSONString: wjson), let public_key = w.publicKey else { return nil }
            
            if let json = try keychain.getWalletAttr(public_key),
                let a = WalletAttributes(JSONString: json) {
                return WalletContainer(wallet: w, attributes: a)
            }
            let a = WalletAttributes(
                publicKey: public_key,
                color: Config.Colors.defaultColor.hex, isActive:true)
            return WalletContainer(wallet: w,
                                   attributes: a)
        }
        catch {
            return nil
        }
    }
    
    public func save(wallet container:WalletContainer) throws {
        
        guard let wallet = container.wallet, let key = wallet.publicKey else {
            throw NSError(domain: "global.mile.wallet.app",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey :  NSLocalizedString("Wallet could not be created from empty public key", comment: ""),
                                     NSLocalizedFailureReasonErrorKey:  NSLocalizedString("Wallet error", comment: "")])
        }
        
        guard let json = Mapper<Wallet>().toJSONString(wallet) else {
            throw NSError(domain: "global.mile.wallet.app",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey :
                            NSLocalizedString("Wallet could not be created for: ", comment: "") + key,
                                     NSLocalizedFailureReasonErrorKey:
                                        NSLocalizedString("Wallet error", comment: "")])
        }
        
        try WalletStore.shared.keychain.set(json, key: key)
        
        guard let attributes = container.attributes, let attr = Mapper<WalletAttributes>().toJSONString(attributes) else {
            throw NSError(domain: "global.mile.wallet.app",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey :  NSLocalizedString("Wallet could not update attributes", comment: ""),
                                     NSLocalizedFailureReasonErrorKey:  NSLocalizedString("Wallet error", comment: "")])
        }
        
        try WalletStore.shared.keychain.setWalletAttr(attr, key: key)
    }
    
    public func remove(key:String) throws {
        try keychain.remove(key)
        try keychain.removeWalletAttr(key)
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
    var publicKey:String = ""
    var color:UInt = Config.Colors.defaultColor.hex
    var isActive:Bool = true
}

extension WalletAttributes: Mappable {
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        publicKey     <- map["public_key"]
        color     <- map["wallet_color"]
        isActive  <- map["is_active"]
    }
}

