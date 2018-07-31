//
//  Printer.swift
//  MileWallet
//
//  Created by denis svinarchuk on 02.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

public class Printer {
    
    public static let shared:Printer = Printer()
    
    public lazy var printController:UIPrintInteractionController = {
        let p = UIPrintInteractionController.shared                
        p.printInfo = printInfo        
        return p
    }()
    
    public func printPDF(wallet:Wallet?,
                  formater:@escaping ((_ wallet:Wallet)->String), 
                  complete:((UIPrintInteractionController, Bool, Error?)->Void)?) {
        
        guard let wallet = wallet else {
            complete?(printController, false, nil)
            return
        }
                
        DispatchQueue.global().async {
            let str = formater(wallet)
            DispatchQueue.main.async {
                let pdf = UIMarkupTextPrintFormatter(markupText: str)
                PDF.generate(using: pdf)
                self.printController.printFormatter = pdf
                self.printController.present(animated: true) { (controller, completed, error) in
                    complete?(controller,completed,error)
                }                    
            }
        }
    }    
    
    private lazy var printInfo:UIPrintInfo = {
        let p = UIPrintInfo(dictionary:nil)
        p.outputType = UIPrintInfoOutputType.general
        p.duplex = .longEdge
        p.orientation = .portrait        
        p.jobName = NSLocalizedString("Wallet printer job", comment: "")
        return p
    }()
    
    
    private init() {}
}
