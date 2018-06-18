//
//  MileSendTrx.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import JSONRPCKit
import ObjectMapper

public struct MileSendTrx: JSONRPCKit.Request{
    
    public typealias Response = Bool
    
    public var transaction_data: String
    
    public var method: String {
        return "send-signed-transaction"
    }
    
    public var parameters: Any? {
        return Mapper<MileSendTrx>().toJSON(self) 
    }
    
    public func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

extension MileSendTrx: Mappable {
    public init?(map: Map) {
        return nil
    }    
    public mutating func mapping(map: Map) {
        transaction_data <- map["transaction_data"]
    }
}

