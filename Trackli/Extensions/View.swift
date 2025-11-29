//
//  View.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 07/04/2025.
//

import SwiftUI
import UIKit

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
