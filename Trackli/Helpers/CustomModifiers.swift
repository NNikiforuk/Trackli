//
//  CustomModifiers.swift
//  Havit
//
//  Created by Natalia Nikiforuk on 27/03/2025.
//
//

import SwiftUICore

struct ElementModifier: ViewModifier {
    func body(content: Content) -> some View {
            content
            .foregroundStyle(.habitText)
            .padding()
            .background(.habitBcg.opacity(0.9))
            .clipShape(.rect(cornerRadius: 15))
        }
}

extension View {
    func elementModifier() -> some View {
        modifier(ElementModifier())
    }
}

struct GeneralStylingModifier: ViewModifier {
    func body(content: Content) -> some View {
            content
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bcg)
            .foregroundStyle(.accent)
        }
}

extension View {
    func generalStylingModifier() -> some View {
        modifier(GeneralStylingModifier())
    }
}
