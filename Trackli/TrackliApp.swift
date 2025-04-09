//
//  TrackliApp.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 09/04/2025.
//

import SwiftUI

@main
struct TrackliApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
