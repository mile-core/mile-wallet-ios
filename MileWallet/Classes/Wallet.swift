//
//  Wallet.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit
import ObjectMapper
import EFQRCode 
import MileCsaLight

public struct Wallet {    

    public var name:String? { return _name }
    public var secretPhrase:String? { return _secretPhrase}
    public var publicKey:String? { return _publicKey }    
    public var privateKey:String? { return _privateKey }    

    public var nameQRImage:UIImage? { return name?.qrCodeImage(with: Config.nameQrPrefix) }
    public var secretPhraseQRImage:UIImage? { return secretPhrase?.qrCodeImage(with: Config.noteQrPrefix)}
    public var publicKeyQRImage:UIImage? { return publicKey?.qrCodeImage(with: Config.publicKeyQrPrefix) }    
    public var privateKeyQRImage:UIImage? { return privateKey?.qrCodeImage(with: Config.privateKeyQrPrefix) }    
    
    public func amountQRImage(_ amount:String) -> UIImage? {
        var a = (publicKey ?? "") 
        a += ":" + amount + ":" + (name ?? "")
        return a.qrCodeImage(with: Config.paymentQrPrefix)
    }
    
    public static func create(name:String, secretPhrase:String?,
                                          error: @escaping ((_ error: SessionTaskError?)-> Void),  
                                          complete: @escaping ((_ wallet: Wallet)->Void)) {                            
        let keys = MileCsa.generateKeys()         
        complete(Wallet(name: name, publicKey: keys.publicKey, privateKey: keys.privateKey, password: secretPhrase))        
    }
        
    public init(name:String, publicKey:String, privateKey:String, password:String?){
        self._name = name 
        self._publicKey = publicKey
        self._privateKey = privateKey
        self._secretPhrase = password
    }    
        
    fileprivate var _name:String?
    fileprivate var _secretPhrase:String?
    fileprivate var _publicKey:String?  
    fileprivate var _privateKey:String?    
}

extension Wallet: Mappable {
    
    public init?(map: Map) {         
    }
    
    public mutating func mapping(map: Map) {
        _name          <- map["wallet_name"]
        _secretPhrase  <- map["secret_phrase"]    
        _publicKey     <- map["public_key"]    
        _privateKey    <- map["private_key"]    
    }
}
