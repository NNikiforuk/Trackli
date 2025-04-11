//
//  FormatMonth.swift
//  Havit
//
//  Created by Natalia Nikiforuk on 27/03/2025.
//

import Foundation

func formatMonth(for weekNumber: Int) -> String {
    let calendar = Calendar.current
    let today = Date()
    
    guard let targetDate = calendar.date(byAdding: .weekOfYear, value: weekNumber, to: today) else {
        return ""
    }
    
    guard let weekStart = calendar.date(
        from: calendar
            .dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: targetDate
            )
    ),
          let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
        return ""
    }
    
    let locale = Locale.current
    
    let startMonthFormatter = DateFormatter()
    startMonthFormatter.locale = locale
    startMonthFormatter.dateFormat = "LLLL"
    let startMonth = startMonthFormatter.string(from: weekStart)
    
    let endMonthFormatter = DateFormatter()
    endMonthFormatter.locale = locale
    endMonthFormatter.dateFormat = "LLLL"
    let endMonth = endMonthFormatter.string(from: weekEnd)
    
    let yearFormatter = DateFormatter()
    yearFormatter.locale = locale
    yearFormatter.dateFormat = "yyyy"
    let year = yearFormatter.string(from: targetDate)
    
    if startMonth != endMonth {
        return "\(startMonth) / \(endMonth) \(year)"
    }
    
    return "\(startMonth) \(year)"
}
