//
//  SettingsView.swift
//  Havit
//
//  Created by Natalia Nikiforuk on 27/03/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") private var selectedAppearance: Appearance = .system
    
    var body: some View {
        NavigationView {
            VStack {
                header
                settingsPicker
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bcg)
        }
    }
    
    var header: some View {
        Text("Settings")
            .font(.title2)
            .fontWeight(.bold)
            .padding(.top, 20)
    }
    
    var settingsPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionSubheadline(title: "Choose appearance")
            VStack {
                Picker("", selection: $selectedAppearance) {
                    ForEach(Appearance.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .foregroundStyle(.customPrimary)
                .background(.habitBcg.opacity(0.9))
                .clipShape(.rect(cornerRadius: 8))
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .padding(.top, 30)
    }
}

#Preview {
    SettingsView()
}
