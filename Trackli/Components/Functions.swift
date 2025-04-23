//
//  Functions.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 23/04/2025.
//

import SwiftUI
import Foundation

func calculateTodaysProgress(todaysHabits: [Habit]) -> CGFloat {
    let todaysHabitsQty = CGFloat(todaysHabits.count)
    let todaysHabitsCompleted = CGFloat(todaysHabits.filter{$0.isCompleted}.count)
    
    return todaysHabitsCompleted / todaysHabitsQty
}
