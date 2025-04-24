//
//  Chart.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 23/04/2025.
//

import SwiftUI

struct Chart: View {
    var todaysHabits: [Habit]
    
    var todaysProgress: CGFloat {
        let todaysHabitsQty = CGFloat(todaysHabits.count)
        let todaysHabitsCompleted = CGFloat(todaysHabits.filter{$0.isCompleted}.count)
        
        return todaysHabitsCompleted / todaysHabitsQty
    }
    
    var percentText: String {
        "\(Int(todaysProgress * 100))%"
    }
    var colorScheme: ColorScheme?
    
    var body: some View {
        ZStack{
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.2)
                .foregroundStyle(.accent)
            Text(percentText)
                .foregroundStyle(.chartText)
            Circle()
                .trim(from: 0.0, to: todaysProgress)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundStyle(.chartText)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: todaysProgress)
        }
        .frame(height: 100)
        .padding(.vertical, 40)
        .preferredColorScheme(colorScheme)
    }
}
