//
//  Chain.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit
import ObjectMapper

public struct Chain {
    
    public var version:String { return _version }
    public var transactions:[String] { return _transactions}
    public var assets:[String:String] { return _assets }
    
    
    public init(version:String, transactions:[String], assets:[String:String]){
        self._version = version
        self._transactions = transactions
        self._assets = assets
    }
    
    public static func update(error: @escaping ((_ error: SessionTaskError?)-> Void),  
                       complete: @escaping ((_ chain: Chain)->Void)) {
        
        let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
        
        //let request = MileAddressState(publicKey: publicKey)
        let request = MileInfo()
        
        let batch = batchFactory.create(request)
        let httpRequest = MileServiceRequest(batch: batch)
        
        Session.send(httpRequest) { (result) in
            switch result {
                
            case .success(let response):
                                                                
                guard let assets = response["supported_assets"] as? NSArray else {
                    return
                }
                
                var newAssets:[String:String] = [:]
                for a in assets {
                    if let o = a as? NSDictionary, 
                        let code = o["code"], 
                        let name = o["name"]{
                        newAssets["\(code)"] = "\(name)"                        
                                                
                    }
                } 
                
                guard let v = response["version"] as? String else  { return } 
                
                guard let trx = response["supported_transactions"] as? NSArray as? Array<String> else { return }                                
                                                                
                complete(Chain(version: v, 
                               transactions: trx, 
                               assets: newAssets))                
                
            case .failure(let er):                
                error(er)
            }
        }     
    }    
    
    fileprivate var _version:String = "1"
    fileprivate var _transactions:[String] = []
    fileprivate var _assets:[String:String] = [:]
    
}

extension Chain:Mappable {
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        _version <- map["version"]
        _transactions <- map["transactions"]
        _assets <- map["assets"]
    }        
}

