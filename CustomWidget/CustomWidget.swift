//
//  CustomWidget.swift
//  CustomWidget
//
//  Created by Natalia Nikiforuk on 09/04/2025.
//

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let habits: [Habit]
    let progress: Double
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), habits: filterUnfinished(), progress: countProgress())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let items = filterUnfinished()
        let entry = SimpleEntry(date: Date(), habits: items, progress: countProgress())
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let items = filterUnfinished()
        let entry = SimpleEntry(date: Date(), habits: items, progress: countProgress())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        
        completion(timeline)
    }
    
    func getData() -> [Habit] {
        let context = PersistenceController.shared.container.viewContext
        let request = Habit.fetchRequest()
        
        do {
            let habits = try context.fetch(request)
            return habits
        } catch {
            print("Error during fetching data: \(error)")
            return []
        }
    }
    
    func filterTodaysHabits() -> [Habit] {
        let habits = getData()
        let calendar = Calendar.current
        let today = Date()
        
        return habits.filter { habit in
            let sameYear = calendar.component(.year, from: habit.startDate!) == calendar.component(.year, from: today)
            let sameDay = calendar.component(.day, from: habit.startDate!) == calendar.component(.day, from: today)
            let sameMonth = calendar.component(.month, from: habit.startDate!) == calendar.component(.month, from: today)
            
            return sameYear && sameDay && sameMonth
        }
    }
    
    func filterUnfinished() -> [Habit] {
        let todaysHabits = filterTodaysHabits()
        
        return todaysHabits.filter{ !$0.isCompleted }
    }
    
    func countProgress() -> Double {
        let habitsTodayCount = Double(filterTodaysHabits().count)
        let completed = Double(filterTodaysHabits().filter{ $0.isCompleted }.count)
        
        return completed / habitsTodayCount
    }
}

struct CustomWidgetEntryView : View {
    var entry: Provider.Entry
    
    var habitsCount: Int {
        entry.habits.count
    }
    
    var body: some View {
        VStack {
           if habitsCount == 0 {
                Text("No pending habits for today!")
           } else {
               HStack {
                   VStack(alignment: .leading) {
                       Text("Pending habits")
                           .font(.caption)
                           .foregroundColor(.secondary)
                           .padding(.bottom, 5)
                       ForEach(entry.habits) { habit in
                           if let title = habit.title {
                               Text(title)
                                   .font(.callout.bold())
                           }
                       }
                       Spacer()
                   }
                   Spacer()
                   VStack {
                       LinearProgressView(progress: entry.progress)
                   }
               }
               Spacer()
           }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.customPrimary)
    }
}

struct LinearProgressView: View {
    var progress: Double
    var progressColor: Color = .customPrimary
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 5)
                    .frame(
                        width: 10,
                        height: geometry.size.height * CGFloat(min(progress, 1.0))
                    )
                    .foregroundColor(progressColor)
                    .animation(.easeOut(duration: 0.8), value: progress)
                
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 10)
                    .foregroundColor(.accent.opacity(0.3))
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: 10)
    }
}

struct CustomWidget: Widget {
    let kind: String = "CustomWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CustomWidgetEntryView(entry: entry)
                    .containerBackground(.widgetBackground, for: .widget)
            } else {
                CustomWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
