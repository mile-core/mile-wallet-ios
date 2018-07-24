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
    
    
    public static let walletService = "GHD7Y8FG8V.global.mile.wallet"  //GHD7Y8FG8V
    public static var isWalletKeychainSynchronizable = true
    
    public struct Colors {
        public static let defaultColor = UIColor(hex: 0x6679FD)
        public static let background = UIColor(patternImage:
            UIImage.gradient(colors: [UIColor(hex: 0xEBF1FE),
                                      UIColor.white],
                             with: UIScreen.main.bounds)!)
        public static let buttonBackground = UIColor.white
        public static let navigationBarTitle =  UIColor(hex: 0x283444)
        public static let navigationBarLargeTitle =  UIColor.white
        public static let name = UIColor.white
        public static let title = name
        public static let button = UIColor(hex: 0xBCC3C3)
        public static let line = UIColor(hex: 0xFFFFFF, alpha: 0.4)
        public static let separator = UIColor(hex: 0x000000, alpha: 0.1)
        public static let placeHolder =  UIColor(hex: 0x283444)
        public static let edit =  UIColor(hex: 0x283444)
        public static let caption =  UIColor(hex: 0x283444)
        public static let infoLine = UIColor(hex: 0x283444, alpha: 0.1)
    }
    
    public struct Images {
        public static let basePattern = UIImage(named: "background-wallet-info")!
    }
    
    public struct Fonts {
        public static let name = UIFont(name: "SFProText-Regular", size: 15)!
        public static let button = name
        public static let amount = UIFont(name: "SFProDisplay-Bold", size: 30)!
        public static let title =  UIFont(name: "SFProText-Semibold", size: 17)!
        public static let navigationBarTitle =  UIFont(name: "SFProText-Regular", size: 21)!
        public static let edit =  UIFont(name: "SFProText-Regular", size: 21)!
        public static let caption =  UIFont(name: "SFProText-Regular", size: 21)!
        public static let navigationBarLargeTitle =  UIFont(name: "SFProDisplay-Bold", size: 34)!
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

