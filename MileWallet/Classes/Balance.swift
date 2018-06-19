//
//  Balance.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit
import ObjectMapper

public struct Balance {
    
    public var balance:[String:String] { return _balance }    
    
    public init(balance:[String:String]){
        self._balance = balance
    }
    
    public static func update(wallet: Wallet, error: @escaping ((_ error: SessionTaskError?)-> Void),  
                              complete: @escaping ((_: Balance)->Void)) {
        
        let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
        
        guard let pk = wallet.publicKey else { return }
        
        let request = MileWalletState(publicKey: pk)
    
        
        let batch = batchFactory.create(request)
        let httpRequest = MileServiceRequest(batch: batch)
        
        Session.send(httpRequest) { (result) in
            switch result {
                
            case .success(let response):
                
                guard let bal = response["balance"] as? NSArray as? Array<AnyObject?> else {
                    return
                }
                
                var balance:[String:String] = [:]
                
                for b in bal {
                    if let o = b as? NSDictionary, 
                        let amount = o["amount"],
                        let code = o["asset_code"]{
                        balance["\(code)"] = "\(amount)" 
                    }
                }                
                                
                complete(Balance(balance: balance))                     
                
            case .failure(let er):                
                error(er)
            }
        }     
    }    
    
    fileprivate var _balance:[String:String] = [:]    
}

extension Balance:Mappable {
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        _balance <- map["balance"]
    }        
}

