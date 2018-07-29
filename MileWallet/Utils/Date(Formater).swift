//
//  Date(Formater).swift
//  MileWallet
//
//  Created by denn on 29.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

extension Date {
    public static var currentTimeString:String {
        let currentDateTime = Date()
        
        let userCalendar = Calendar.current
        
        let requestedComponents: Set<Calendar.Component> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second
        ]
        
        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)
        
        return String(format: "%i-%i-%i %i-%i-%i:%i",
                      dateTimeComponents.year!,
                      dateTimeComponents.month!,
                      dateTimeComponents.day!,
                      dateTimeComponents.hour!,
                      dateTimeComponents.minute!,
                      dateTimeComponents.second!)
    }
}
