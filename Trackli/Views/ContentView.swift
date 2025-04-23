//
//  ContentView.swift
//  Trackli
//
//  Created by Natalia Nikiforuk on 09/04/2025.
//

import SwiftUI
import CoreData
import WidgetKit

struct ContentView: View {
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
    @State private var weekRange: ClosedRange<Int> = -50...50
    
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
    
    var todaysProgress: CGFloat {
        let todaysHabitsQty = CGFloat(todaysHabits.count)
        let todaysHabitsCompleted = CGFloat(todaysHabits.filter{$0.isCompleted}.count)
        
        return todaysHabitsCompleted / todaysHabitsQty
    }
    
    var body: some View {
        NavigationView {
            VStack {
//                calendar
//                if todaysHabits.isEmpty {
//                    noChart
//                } else {
//                    Chart(todaysProgress: todaysProgress, colorScheme: colorScheme)
//                }
                VStack {
                    habitsHeader
                    VStack {
                        if todaysHabits.isEmpty {
                            noNotes
                        } else {
                            Habits(todaysHabits: todaysHabits)
                        }
                        Spacer()
                    }
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bcg)
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    NavigationLink(destination: SettingsView(colorScheme: colorScheme)) {
//                        Image(systemName: "gearshape")
//                            .font(.body.bold())
//                    }
//                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        showAlert.toggle()
//                    } label: {
//                        Text(LocalizedStringKey("Delete all"))
//                        Image(systemName: "trash")
//                    }
//                }
//            }
            .foregroundStyle(.accent)
            .alert(LocalizedStringKey(alertTitle), isPresented: $showAlert) {
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
        .preferredColorScheme(colorScheme)
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
    
    var noNotes: some View {
        Text(LocalizedStringKey("No data"))
            .padding(.top, 20)
            .foregroundStyle(.primaryText)
    }
    
    var noChart: some View {
        Text("")
            .frame(height: 100)
            .padding(.vertical, 40)
    }
    
    var habitsHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(LocalizedStringKey("Today's habits"))
                .foregroundStyle(.primaryText)
                .font(.title2.bold())
            Spacer()
            NavigationLink(destination: AddHabitView()) {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(.accent)
                    .font(.title)
            }
        }
        .padding(.bottom, 20)
        .padding(.horizontal)
    }
}

struct Habits: View {
    var todaysHabits: [Habit]
    
    var body: some View {
        ScrollView {
            ForEach(todaysHabits) { habit in
                SingleHabitView(habit: habit)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct SingleHabitView: View {
    @ObservedObject var habit: Habit
    
    var body: some View {
        HStack {
            if let title = habit.title as String?, let isCompleted = habit.isCompleted as Bool? {
                if let attributedText = try? AttributedString(markdown: isCompleted ? "~~\(title)~~" : title) {
                    Text(attributedText)
                        .font(.headline.bold())
                        .foregroundStyle(.habitText)
                } else {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundStyle(.habitText)
                }
                Spacer()
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.largeTitle)
                    .foregroundStyle(.customPrimary)
            }
        }
        .foregroundStyle(.customPrimary)
        .elementModifier()
        .onTapGesture {
            habit.isCompleted.toggle()
            try? habit.managedObjectContext?.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

#Preview {
    ContentView()
}
