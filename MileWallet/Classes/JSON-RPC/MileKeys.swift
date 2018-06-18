//
//  MileKeys.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import JSONRPCKit
import ObjectMapper

public struct MileKeys: JSONRPCKit.Request{
               
    public typealias Response = [String:Any]
    
    public var wallet_name: String
    public var password: String
    
    public var method: String {
        return "get-wallet-keys"
    }
    
    public var parameters: Any? {
        return Mapper<MileKeys>().toJSON(self) 
    }
    
    public func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

extension MileKeys: Mappable {
    public init?(map: Map) {
        return nil
    }    
    public mutating func mapping(map: Map) {
        wallet_name <- map["wallet_name"]
        password    <- map["password"]    
    }
}
