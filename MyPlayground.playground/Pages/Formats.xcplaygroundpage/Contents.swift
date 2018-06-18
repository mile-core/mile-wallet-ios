//: [Previous](@previous)

import Foundation
import PDFGenerator

private let numberFormatter:NumberFormatter = { 
    let f = NumberFormatter()
    f.numberStyle = .none
    return f
}()

numberFormatter.locale = Locale.current

var n = numberFormatter.number(from: "1,0")?.floatValue

extension String {
    static let numberFormatter = NumberFormatter()
    var floatValue: Float {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.floatValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.floatValue
            }
        }
        return 0
    }
}

"1,0".floatValue
"1.0".floatValue


//: [Next](@next)
