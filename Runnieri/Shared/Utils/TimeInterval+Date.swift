//
//  TimeInterval+Date.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 11/06/2025.
//

import Foundation

extension TimeInterval {
    /// Returns the date by adding this time interval to the year 1970.
    var absoluteDate: Date {
        Date(timeIntervalSince1970: self)
    }
}
