//
//  HomeView.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 23/04/2025.
//

import SwiftUI
import CoreData
import WidgetKit

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("appearance") private var selectedAppearance: Appearance = .system
    @Namespace private var animation
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.isCompleted, ascending: true)],
        animation: .default)
    private var habits: FetchedResults<Habit>
    
    @State private var selectedDate = Date()
    @State private var currentPage = 0
    @State private var showAlert = false
    
    var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case .system:
            return nil
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
    
    var isNoData: Bool {
        habits.isEmpty
    }
    
    var alertTitle: String {
        return isNoData ? "There is no data already" : "Do you want to delete all habits?"
    }
    
    var todaysHabits: [Habit] {
        return habits.filter { habit in
            let calendar = Calendar.current
            let sameYear = calendar.component(.year, from: habit.startDate!) == calendar.component(.year, from: selectedDate)
            let sameDay = calendar.component(.day, from: habit.startDate!) == calendar.component(.day, from: selectedDate)
            let sameMonth = calendar.component(.month, from: habit.startDate!) == calendar.component(.month, from: selectedDate)
            
            return sameYear && sameDay && sameMonth
        }
    }
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        if isIPad {
            VStack {
                HStack {
                    SettingsPicker(isIPad: isIPad)
                    Spacer()
                    deleteBtn
                }
                MainContent(currentPage: $currentPage, selectedDate: $selectedDate, isIPad: isIPad, todaysHabits: todaysHabits, colorScheme: colorScheme)
            }
            .generalStylingModifier()
            .alert(LocalizedStringKey(alertTitle), isPresented: $showAlert) {
                deletingAlert
            }
            .preferredColorScheme(colorScheme)
        } else {
            NavigationView {
                MainContent(currentPage: $currentPage, selectedDate: $selectedDate, isIPad: isIPad, todaysHabits: todaysHabits, colorScheme: colorScheme)
                    .generalStylingModifier()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            NavigationLink(destination: Settings(colorScheme: colorScheme, isIPad: isIPad)) {
                                Image(systemName: "gearshape")
                                    .font(.body.bold())
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            deleteBtn
                        }
                    }
                    .alert(LocalizedStringKey(alertTitle), isPresented: $showAlert) {
                        deletingAlert
                    }
            }
            .preferredColorScheme(colorScheme)
        }
    }
    
    var deletingAlert: some View {
        VStack {
            if isNoData {
                Button("Ok", role: .cancel) { }
            } else {
                Button(LocalizedStringKey("Yes"), role: .destructive) {
                    performDeleting()
                }
                Button(LocalizedStringKey("No"), role: .cancel) { }
            }
        }
    }
    
    var deleteBtn: some View {
        Button {
            showAlert.toggle()
        } label: {
            Text(LocalizedStringKey("Delete all"))
            Image(systemName: "trash")
        }
    }
    
    func performDeleting() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Habit.fetchRequest()
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        batchDeleteRequest1.resultType = .resultTypeObjectIDs
        
        do {
            if let result = try viewContext.execute(batchDeleteRequest1) as? NSBatchDeleteResult,
               let objectIDArray = result.result as? [NSManagedObjectID] {
                
                let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
            }
            try viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print(error)
        }
    }
}

#Preview {
    HomeView()
}
