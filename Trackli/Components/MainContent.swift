//
//  MainContent.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 23/04/2025.
//

import SwiftUI

struct MainContent: View {
    @Binding var currentPage: Int
    @Binding var selectedDate: Date
    
    let isIPad: Bool
    let todaysHabits: [Habit]
    let colorScheme: ColorScheme?
    
    @State private var isAdding = false
    
    var body: some View {
        VStack {
            CalendarTab(currentPage: $currentPage, selectedDate: $selectedDate, isIPad: isIPad)
            if todaysHabits.isEmpty {
                NoChart()
            } else {
                Chart(todaysHabits: todaysHabits, colorScheme: colorScheme)
            }
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Text(LocalizedStringKey("Today's habits"))
                        .foregroundStyle(.primaryText)
                        .font(isIPad ? .title.bold() : .title2.bold())
                    Spacer()
                    if isIPad {
                        Button {
                            isAdding.toggle()
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.largeTitle)
                        }
                    } else {
                        NavigationLink(destination: AddHabitView()) {
                            Image(systemName: "square.and.pencil")
                                .foregroundStyle(.accent)
                                .font(.title)
                        }
                    }
                }
                .padding(.bottom, 20)
                .padding(.horizontal)
                VStack {
                    if todaysHabits.isEmpty {
                        NoNotes()
                    } else {
                        ScrollView {
                            ForEach(todaysHabits) { habit in
                                SingleHabit(habit: habit)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    Spacer()
                }
            }
            Spacer()
        }
        .sheet(isPresented: $isAdding) {
            AddHabitView()
        }
    }
}
