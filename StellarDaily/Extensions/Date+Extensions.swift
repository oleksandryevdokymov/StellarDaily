//
//  Date+Extensions.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation

extension Date {
    var apodString: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
