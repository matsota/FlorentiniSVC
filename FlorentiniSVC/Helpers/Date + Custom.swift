//
//  Date + Custom.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 19.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation

extension Date {
     func asString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: self)
    }
}
