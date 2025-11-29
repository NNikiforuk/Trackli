//
//  CalendarTab.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 23/04/2025.
//

import Foundation
import SwiftUI

struct CalendarTab: View {
    @Binding var currentPage: Int
    @Binding var selectedDate: Date
    @State private var weekRange: ClosedRange<Int> = -50...50
    
    var body: some View {
        VStack {
            Text(formatMonth(for: currentPage))
                .font(.title2.bold())
                .foregroundColor(.primaryText)
                .padding(.top, 20)
            TabView(selection: $currentPage) {
                ForEach(weekRange, id: \.self) { weekNumber in
                    Week(
                        selectedDate: $selectedDate,
                        weekNumber: weekNumber
                    )
                    .tag(weekNumber)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 100)
            .onChange(of: currentPage) { newValue in
                if newValue == weekRange.upperBound {
                    weekRange = weekRange.lowerBound ... (weekRange.upperBound + 50)
                }
                else if newValue == weekRange.lowerBound {
                    weekRange = (weekRange.lowerBound - 50) ... weekRange.upperBound
                }
            }
        }
    }
}
