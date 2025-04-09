//
//  Helpers.swift
//  Havit
//
//  Created by Natalia Nikiforuk on 19/03/2025.
//

import Foundation
import SwiftUICore

enum Theme: String, CaseIterable {
    case systemDefault = "Default"
    case light = "Light"
    case dark = "Dark"
    
    static var selectableCases: [Theme] {
        [.light, .dark]
    }
    
    func color(_ scheme: ColorScheme) -> Color {
        switch self {
        case .systemDefault:
            return scheme == .dark ? .gray : .yellow
        case .light:
            return .yellow
        case .dark:
            return .gray
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .systemDefault:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var iconName: String {
        switch self {
        case .systemDefault:
            return "sun.max.fill"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}


