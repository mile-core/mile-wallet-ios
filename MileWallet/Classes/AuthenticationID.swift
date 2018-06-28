//
//  AuthenticationID.swift
//  MileWallet
//
//  Created by denis svinarchuk on 28.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import LocalAuthentication

protocol AuthenticationID {    }

extension AuthenticationID {
    
    func authenticate(error errorHandler:((_:Error)->Void)?=nil, 
                      success completeHandler:@escaping (()->Void)) {
        
        let policy = LAPolicy.deviceOwnerAuthentication
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = NSLocalizedString("Use Passcode", comment: "") 
        
        var authError: NSError?
        let reasonString = NSLocalizedString("To access the secure data", comment: "")
        
        if localAuthenticationContext.canEvaluatePolicy(policy, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(policy, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    //TODO: User authenticated successfully, take appropriate action
                    
                    completeHandler()
                                        
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action                                        
                    guard let error = evaluateError else {
                        return
                    }                    
                    print(self.authenticationPolicyMessage(errorCode: error._code))                                                                                                        
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    errorHandler?(error)
                }
            }
        } else {        
            guard let error = authError else {
                return
            }            
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print(self.authenticationPolicyMessage(errorCode: error.code))
            
        }
    }
    
    func policyFailMessage(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func authenticationPolicyMessage(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            exit(1)
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = policyFailMessage(errorCode: errorCode)
        }
        
        return message
    }
}

