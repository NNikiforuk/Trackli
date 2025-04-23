//
//  SettingsView.swift
//  Havit
//
//  Created by Natalia Nikiforuk on 27/03/2025.
//

import SwiftUI

struct SettingsView: View {
    var colorScheme: ColorScheme?
    let isIPad: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                header
                SettingsPicker(isIPad: isIPad)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bcg)
        }
        .preferredColorScheme(colorScheme)
    }
    
    var header: some View {
        Text(LocalizedStringKey("Settings"))
            .font(.title2)
            .fontWeight(.bold)
            .padding(.top, 20)
    }
}

struct SettingsPicker: View {
    @AppStorage("appearance") private var selectedAppearance: Appearance = .system
    let isIPad: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !isIPad {
                SectionSubheadline(title: "Theme")
                    .foregroundStyle(.accent)
            }
            VStack {
                Picker("", selection: $selectedAppearance) {
                    ForEach(Appearance.allCases) { mode in
                        Text(LocalizedStringKey(mode.rawValue)).tag(mode)
                    }
                }
                .background(isIPad ? .bcg : .habitBcg.opacity(0.9))
                .clipShape(.rect(cornerRadius: 8))
                .labelsHidden()
                .pickerStyleForDevice(isIPad: UIDevice.current.userInterfaceIdiom == .pad)
            }
        }
        .padding(.top, 30)
    }
}

extension View {
    @ViewBuilder
    func pickerStyleForDevice(isIPad: Bool) -> some View {
        if isIPad {
            self.pickerStyle(MenuPickerStyle())
        } else {
            self.pickerStyle(SegmentedPickerStyle())
        }
    }
}

#Preview {
    SettingsView(colorScheme: .light, isIPad: false)
}
