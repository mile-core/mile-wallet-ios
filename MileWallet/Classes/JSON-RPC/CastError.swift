//
//  CastError.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit

struct CastError<ExpectedType>: Error {
    let actualValue: Any
    let expectedType: ExpectedType.Type
}

extension JSONRPCKit.JSONRPCError {
    var what:String {                
        switch self {
        case .responseError(_, let message, _):
            return message
        case .responseNotFound(_,_):
            return NSLocalizedString("Response not found...", comment: "")
        case .resultObjectParseError(_):
            return NSLocalizedString("Result object parse error", comment: "")
        case .unsupportedVersion(_):
            return NSLocalizedString("API Unsupported version", comment: "")
        case .unexpectedTypeObject(_), .missingBothResultAndError(_), .nonArrayResponse(_), .errorObjectParseError(_):
            return NSLocalizedString("Result object parse fail", comment: "")
        }
    }    
}

extension SessionTaskError {
    var whatResponse:String? {        
        let error = self         
        var jsonrpcError:JSONRPCKit.JSONRPCError?
        
        switch error {
        case .responseError(let error), .connectionError(let error), .requestError(let error): 
            jsonrpcError = error as? JSONRPCKit.JSONRPCError               
        }
        
        guard let responseError = jsonrpcError else { return nil }
        
        return responseError.what
    }    
}
