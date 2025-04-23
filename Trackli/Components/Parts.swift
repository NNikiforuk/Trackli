//
//  Parts.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 23/04/2025.
//

import Foundation
import SwiftUI


struct NoChart: View {
    var body: some  View {
        Text("")
            .frame(height: 100)
            .padding(.vertical, 40)
    }
}

struct NoNotes: View {
    var body: some  View {
        Text(LocalizedStringKey("No data"))
            .padding(.top, 20)
            .foregroundStyle(.primaryText)
    }
}
