//
//  MileWalletState.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import JSONRPCKit
import ObjectMapper

public struct MileWalletState: JSONRPCKit.Request{
    
    public typealias Response = [String:Any]
    
    public var publicKey: String
    
    public var method: String {
        return "get-wallet-state"
    }
    
    public var parameters: Any? {
        return Mapper<MileWalletState>().toJSON(self) 
    }
    
    public func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

extension MileWalletState: Mappable {
    public init?(map: Map) {
        return nil
    }    
    public mutating func mapping(map: Map) {
        publicKey <- map["public_key"]
    }
}
