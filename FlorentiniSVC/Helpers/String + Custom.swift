//
//  String + Custom.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 06.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation

extension String {
    func countQuantityForCertainPartOfString(string: String) -> Int{
        var array = [String]()
        let separateSymbols = "(), "
        for i in self.lowercased()
            .components(separatedBy: CharacterSet(charactersIn: separateSymbols))
            .filter({x in x != ""}) {
                array.append(i)
        }
        return array.filter{$0 == string}.count
    }
    
    func convertStringIntoArray() -> [String]{
        var array = [String]()
        let separateSymbols = "(), /@#%^&*!?+;:.~`"
        for i in self.lowercased()
            .components(separatedBy: CharacterSet(charactersIn: separateSymbols))
            .filter({x in x != ""}) {
                array.append(i)
        }
        return array
    }
}
