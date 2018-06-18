//
//  Transfer.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit
import ObjectMapper

public struct Transfer {
    
    public var transactionData:String? { return _transactionData }    
    public var result:Bool { return _result }    
    
//    public init(balance:[String:String]){
//        self._balance = balance
//    }
    
    public static func send(asset: String, amount: String, from: Wallet, to: Wallet, 
                            error: @escaping ((_ error: SessionTaskError?)-> Void),  
                            complete: @escaping ((_ chain: Transfer)->Void)) {
        
        let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
        
        guard let from_key = from.publicKey else { return }
        guard let to_key = to.publicKey else { return }
        guard let from_private_key = from.privateKey else { return }
                
        let request = MilePrepareTrx(asset: asset, 
                                     amount: amount, 
                                     from: from_key, 
                                     to: to_key, 
                                     privateKey: from_private_key) 
        
                
        let batch = batchFactory.create(request)
        let httpRequest = MileServiceRequest(batch: batch)
        
        Session.send(httpRequest) { (result) in
            switch result {                
            case .success(let response):
                
                guard let data = response["transaction_data"]  else {
                    return
                }
                                
                let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
                
                let request = MileSendTrx(transaction_data: "\(data)")
                
                let batch = batchFactory.create(request)
                let httpRequest = MileServiceRequest(batch: batch)
                
                Session.send(httpRequest) { (result) in
                    switch result {    
                        
                    case .success(let response):
                        
                        Swift.print("send transaction_data: ", response)

                        complete(Transfer())                     
                        
                    case .failure(let er):                
                        error(er)
                    }
                }                                
            case .failure(let er):                
                error(er)
            }
        }     
    }    
    
    fileprivate var _transactionData:String?      
    fileprivate var _result:Bool = false      
}

extension Transfer :Mappable {
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        _transactionData <- map["transaction_data"]
        _result <- map["result"]
    }        
}

