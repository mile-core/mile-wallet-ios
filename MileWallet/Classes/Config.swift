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
    
    
    public static let walletService = "GHD7Y8FG8V.global.mile.wallet" //(appIdentifierPrefix() ?? "") +     
    public static var isWalletKeychainSynchronizable = true
    
    public struct Colors {
        public static let background = UIColor.white
        public static let buttonBackground = UIColor.white
    }    
    
    static func appIdentifierPrefix() -> String? {
        let queryLoad: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "bundleSeedID" as AnyObject,
            kSecAttrService as String: "" as AnyObject,
            kSecReturnAttributes as String: kCFBooleanTrue
        ]
        
        var result : AnyObject?
        var status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if status == errSecItemNotFound {
            status = withUnsafeMutablePointer(to: &result) {
                SecItemAdd(queryLoad as CFDictionary, UnsafeMutablePointer($0))
            }
        }
        
        if status == noErr {
            if let resultDict = result as? Dictionary<String, Any>, let accessGroup = resultDict[kSecAttrAccessGroup as String] as? String {
                let components = accessGroup.components(separatedBy: ".")
                return components.first
            }else {
                return nil
            }
        } else {
            print("Error getting bundleSeedID to Keychain")
            return nil
        }
    }
}

