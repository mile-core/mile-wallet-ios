//
//  PasscodeStore.swift
//  MileWallet
//
//  Created by denn on 01.08.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import KeychainAccess
import MileWalletKit

public class PasscodeStrore {
    
    public let passcodeLength = 6
    public static let shared = PasscodeStrore()
    
    public var isRegistered:Bool {
        do {
            return try appPasscodeStore.contains(PasscodeStrore.key)
        }
        catch {
            return false
        }
    }
    
    @discardableResult public func reset(old: String, new: String) -> Bool {
        do {
            if isRegistered {
                guard validate(code: old) else {
                    return false
                }
            }
            if new.count >= passcodeLength {
                try appPasscodeStore.set(new, key: PasscodeStrore.key)
                return true
            }
        }
        catch let error {
            print("PasscodeStrore: \(error)")
        }
        return false
    }
    
    public func validate(code: String) -> Bool {
        do {
            
            //
            // try PasscodeStrore.shared.appPasscodeStore.remove(PasscodeStrore.key)
            //
            
            guard isRegistered else {
                return false
            }
            
            if let pass =  try appPasscodeStore.get(PasscodeStrore.key) {
                return pass == code
            }
            return false
        }
        catch let error {
            print("PasscodeStrore: \(error)")
            return false
        }
    }
    
    private static let key = "wallet-passcode"
    private static let appPasscodeService = "GHD7Y8FG8V.global.mile.wallet-passcode"
    private let appPasscodeStore
        = Keychain(accessGroup: appPasscodeService)
            .synchronizable(Config.isWalletKeychainSynchronizable)
    
    private init() {}
}
