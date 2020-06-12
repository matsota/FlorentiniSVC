//
//  Array + Custom.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 11.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation


extension Array {
    func insertionIndexOf(_ elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var low = 0
        var high = self.count - 1
        while low <= high {
            let mid = (low + high)/2
            if isOrderedBefore(self[mid], elem) {
                low = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                high = mid - 1
            } else {
                return mid
            }
        }
        return low // not found, would be inserted at position lo
    }
}
