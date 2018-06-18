//
//  MileServiceRequest.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit

struct MileServiceRequest<Batch: JSONRPCKit.Batch>: APIKit.Request {
    let batch: Batch
    
    typealias Response = Batch.Responses
    
    var baseURL: URL {
        return URL(string: Config.mileHosts[0])!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/v1/api"
    }
    
    var parameters: Any? {
        return batch.requestObject
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try batch.responses(from: object)
    }
}
