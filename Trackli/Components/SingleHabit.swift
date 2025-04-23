//
//  SingleHabit.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 23/04/2025.
//

import SwiftUI
import WidgetKit

struct SingleHabit: View {
    @ObservedObject var habit: Habit
    
    var body: some View {
        HStack {
            if let title = habit.title as String?, let isCompleted = habit.isCompleted as Bool? {
                if let attributedText = try? AttributedString(markdown: isCompleted ? "~~\(title)~~" : title) {
                    Text(attributedText)
                        .font(.headline.bold())
                        .foregroundStyle(.habitText)
                } else {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundStyle(.habitText)
                }
                Spacer()
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.largeTitle)
                    .foregroundStyle(.customPrimary)
            }
        }
        .foregroundStyle(.customPrimary)
        .elementModifier()
        .onTapGesture {
            habit.isCompleted.toggle()
            try? habit.managedObjectContext?.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

