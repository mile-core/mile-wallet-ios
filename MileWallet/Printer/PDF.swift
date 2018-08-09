//
//  PDF.swift
//  MileWallet
//
//  Created by denis svinarchuk on 14.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

class PDF {
    
    /**
     Generates a PDF using the given print formatter and saves it to the user's document directory.
     
     - parameters:
     - printFormatter: The print formatter used to generate the PDF.
     
     - returns: The generated PDF.
     */
    @discardableResult class func generate(using printFormatter: UIPrintFormatter) -> Data {
        
        // assign the print formatter to the print page renderer
        let renderer = UIPrintPageRenderer()
        
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        // assign paperRect and printableRect values
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(page, forKey: "printableRect")
        
        // create pdf context and draw each page
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext();
        
        return pdfData as Data
    }        
}
