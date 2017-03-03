//
//  StringExtension.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-23.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

extension String {
    
    //method checks if a strings starts with the string passed as parameter
    func startsWith(string: String) -> Bool {
        guard let range = range(of: string, options:[.caseInsensitive]) else {
            return false
        }
        return range.lowerBound == startIndex
    }
    
}

