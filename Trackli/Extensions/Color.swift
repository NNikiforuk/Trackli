//
//  Color.swift
//  Havit
//
//  Created by Natalia Nikiforuk on 21/03/2025.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let bcg = Color("BcgColor")
    let habitBcg = Color("HabitBcgColor")
    let primaryText = Color("PrimaryTextColor")
    let secondaryText = Color("SecondaryTextColor")
    let customPrimary = Color("CustomPrimary")
    let whiteText = Color("WhiteText")
    let habitText = Color("HabitTextColor")
    let calendarText = Color("CalendarTextColor")
}
