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
import MileCsaLight

public struct Transfer {
        
    public var transactionData:String? { return _transactionData }    
    public var result:Bool { return _result }    
        
    public static func send(asset: String, 
                            amount: String, 
                            from: Wallet, to: Wallet, 
                            error: @escaping ((_ error: SessionTaskError?)-> Void),  
                            complete: @escaping ((_: Transfer)->Void)) {
        
        
        Chain.update(error: { (err) in
            error(err)
        }) { (chain) in
            Swift.print(chain.assets)
        }
        
        let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
        
        guard let from_key = from.publicKey else { return }
        guard let to_key = to.publicKey else { return }
        guard let from_private_key = from.privateKey else { return }
                
        let request = MileWalletState(publicKey: from_key)
                
        let batch = batchFactory.create(request)
        let httpRequest = MileServiceRequest(batch: batch)
        
        Session.send(httpRequest) { (result) in
            switch result {                
            case .success(let response):
                
                
                guard let trxId = response["last_transaction_id"] else {
                    error(.responseError(ResponseError.unexpectedObject(response)))
                    return
                }
                
                let data = MileCsa.createTransfer(MileCsaKeys(from_key, privateKey: from_private_key), 
                                                              destPublicKey: to_key, 
                                                              transactionId: "\(trxId)", 
                                                              assets: 1, 
                                                              amount: amount)
                                                
                let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
                
                let request = MileSendTrx(transaction_data: data)
                
                
                let batch = batchFactory.create(request)
                let httpRequest = MileServiceRequest(batch: batch)
                
                Swift.print("MileSendTrx : \(httpRequest)")

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

