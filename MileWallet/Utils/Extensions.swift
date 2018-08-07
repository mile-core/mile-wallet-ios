//
//  Extensions.swift
//  MileWallet
//
//  Created by denis svinarchuk on 03.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

public extension UIAlertController {
    
    @discardableResult
    func addAction(title: String?, style: UIAlertActionStyle = .default, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        addAction(UIAlertAction(title: title, style: style, handler: handler))
        return self
    }
    
    func present(by viewController: UIViewController) {
        viewController.present(self, animated: true)
    }
}


public struct Semaphore {
    private let s = DispatchSemaphore(value: 1)
    public init() {}
    @discardableResult public func sync<R>(execute: () throws -> R) rethrows -> R {
        _ = s.wait(timeout: DispatchTime.distantFuture)
        defer { s.signal() }
        return try execute()
    }
}
