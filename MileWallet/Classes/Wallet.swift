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

public struct Wallet {    

    public var name:String? { return _name }
    public var secretPhrase:String? { return _secretPhrase}
    public var publicKey:String? { return _publicKey }    
    public var privateKey:String? { return _privateKey }    

    public var nameQRImage:UIImage? { return name?.qrCodeImage(with: Config.noteQrPrefix+":NAME:") }
    public var secretPhraseQRImage:UIImage? { return secretPhrase?.qrCodeImage(with: Config.noteQrPrefix)}
    public var publicKeyQRImage:UIImage? { return publicKey?.qrCodeImage(with: Config.publicKeyQrPrefix) }    
    public var privateKeyQRImage:UIImage? { return privateKey?.qrCodeImage(with: Config.privateKeyQrPrefix) }    
    
    public func amountQRImage(_ amount:String) -> UIImage? {
        var a = (publicKey ?? "") 
        a += ":" + amount + ":" + (name ?? "")
        return a.qrCodeImage(with: Config.paymentQrPrefix)
    }
    
    public static func create(name:String, secretPhrase:String,
                                          error: @escaping ((_ error: SessionTaskError?)-> Void),  
                                          complete: @escaping ((_ wallet: Wallet)->Void)) {
        
        let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
        
        let request = MileKeys(wallet_name: name, password: secretPhrase) 
        
        let batch = batchFactory.create(request)
        let httpRequest = MileServiceRequest(batch: batch)
                
        Session.send(httpRequest) { (result) in
            switch result {
            case .success(let response):
                
                if let pubk = response["public_key"] as? String,
                    let privk = response["private_key"] as? String {
                    complete(Wallet(name: name, publicKey: pubk, privateKey: privk, password: secretPhrase))
                }
                
            case .failure(let er):                
                
                Swift.print("Create passwd = \(er)")
                
                let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
                
                let request = MileAddress(wallet_name: name, password: secretPhrase) 
                
                let batch = batchFactory.create(request)
                let httpRequest = MileServiceRequest(batch: batch)
                
                Session.send(httpRequest) { (result) in
                    switch result {
                    case .success(let response):
                        
                        if let pubk = response["public_key"] as? String,
                            let privk = response["private_key"] as? String {
                            complete(Wallet(name: name, publicKey: pubk, privateKey: privk, password: secretPhrase))
                        }
                    case .failure(let er):                
                        error(er)
                    }
                }                
            }
        }                        
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
