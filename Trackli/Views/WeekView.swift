//
//  WeekView.swift
//  Havit
//
//  Created by Natalia Nikiforuk on 19/03/2025.
//

import SwiftUI

struct WeekView: View {
    @Binding var selectedDate: Date
    let weekNumber: Int
    
    var body: some View {
        HStack {
            ForEach(getDaysOfWeek(for: weekNumber), id: \.self) { date in
                VStack {
                    Text(formatDayName(date))
                        .font(.caption)
                        .foregroundColor(.calendarText)
                        .fontWeight(isSameDay(date1: date, date2: selectedDate) ? .bold : .regular)
                    Text(formatDayNumber(date))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.whiteText)
                        .frame(width: 40, height: 40)
                        .padding(.top, 0)
                        .background(
                            isSameDay(date1: date, date2: selectedDate)
                            ? .customPrimary
                            : .customPrimary.opacity(0.5)
                        )
                        .clipShape(Circle())
                }
                .onTapGesture {
                    withAnimation {
                        selectedDate = date
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func getDaysOfWeek(for weekNumber: Int) -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        guard let firstDayOfWeek = calendar.date(from: components) else { return [] }
        
        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: weekNumber, to: firstDayOfWeek) else { return [] }
        
        return (0...6).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: targetDate)
        }
    }
    
    private func formatDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func formatDayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}

#Preview {
    WeekView(selectedDate: .constant(Date()), weekNumber: 0)
}
