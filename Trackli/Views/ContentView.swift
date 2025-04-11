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
    
    let weeks = -50...50
    
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
                calendar
                if todaysHabits.isEmpty {
                    noChart
                } else {
                    Chart(todaysProgress: todaysProgress, colorScheme: colorScheme)
                }
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.body.bold())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAlert.toggle()
                    } label: {
                        Text(LocalizedStringKey("Delete all"))
                            .font(.body.bold())
                        Image(systemName: "trash")
                            .font(.caption.bold())
                    }
                }
            }
            .foregroundStyle(.accent)
            .alert("Do you want to delete all habits?", isPresented: $showAlert) {
                Button("Yes", role: .destructive) { deleteAllHabits() }
                Button("No", role: .cancel) { }
            }
        }
        .preferredColorScheme(colorScheme)
    }
    
    func deleteAllHabits() {
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
        HStack(alignment: .center) {
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
    
    var calendar: some View {
        VStack {
            Text(formatMonth(for: currentPage))
                .font(.title2.bold())
                .foregroundColor(.primaryText)
                .padding(.top, 20)
            TabView(selection: $currentPage) {
                ForEach(weeks, id: \.self) { weekNumber in
                    WeekView(
                        selectedDate: $selectedDate,
                        weekNumber: weekNumber
                    )
                    .tag(weekNumber)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 100)
        }
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

struct Chart: View {
    var todaysProgress: CGFloat
    var percentText: String {
        "\(Int(todaysProgress * 100))%"
    }
    var colorScheme: ColorScheme?
    
    var body: some View {
        ZStack{
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.2)
                .foregroundStyle(.accent)
            Text(percentText)
                .foregroundStyle(.chartText)
            Circle()
                .trim(from: 0.0, to: todaysProgress)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundStyle(.chartText)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: todaysProgress)
        }
        .frame(height: 100)
        .padding(.vertical, 40)
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    ContentView()
}
