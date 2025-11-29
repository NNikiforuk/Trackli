//
//  Weekday.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 14/04/2025.
//

import SwiftUI

enum Weekday: String, CaseIterable, Identifiable {
    case mon = "Mon", tue = "Tue", wed = "Wed", thu = "Thu", fri = "Fri", sat = "Sat", sun = "Sun"
    
    var id: String { rawValue }

    static func from(date: Date) -> Weekday? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        let key = formatter.string(from: date)
        return Weekday(rawValue: key)
    }
}
