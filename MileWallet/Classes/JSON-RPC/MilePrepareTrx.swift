//
//  MilePrepareTrx.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import JSONRPCKit
import ObjectMapper

public struct MilePrepareTrx: JSONRPCKit.Request{
    
    public typealias Response = [String:Any]
    
    public var asset: String
    public var amount: String
    public var from: String
    public var to: String
    public var privateKey: String
    
    public var method: String {
        return "get-transfer-assets-transaction"
    }
    
    public var parameters: Any? {
        return Mapper<MilePrepareTrx>().toJSON(self) 
    }
    
    public func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

extension MilePrepareTrx: Mappable {
    public init?(map: Map) {
        return nil
    }    
    public mutating func mapping(map: Map) {
        asset <- map["asset"]
        amount  <- map["amount"]    
        from  <- map["from"]    
        to  <- map["to"]   
        privateKey <- map["private_key"]
    }
}

