//
//  Appearance.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 10/04/2025.
//

enum Appearance: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
}


