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
    
    let todaysHabits: [Habit]
    
    @State private var isAdding = false
    @State private var refreshTrigger = false
    
    var body: some View {
        VStack {
            CalendarTab(currentPage: $currentPage, selectedDate: $selectedDate)
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Text("Today's habits")
                        .foregroundStyle(.primaryText)
                        .font(.title2.bold())
                    Spacer()
                    NavigationLink(destination: AddHabitView()) {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(.accent)
                            .font(.title)
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
                                SingleHabit(habit: habit, refreshTrigger: $refreshTrigger)
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
