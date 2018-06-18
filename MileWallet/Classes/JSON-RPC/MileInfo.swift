//
//  MileInfo.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct MileInfo: JSONRPCKit.Request {
    
    public typealias Response = [String:Any]
        
    public var method: String {
        return "get-blockchain-info"
    }
    
    public var parameters: Any? {
        return []
    }
    
    public func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

