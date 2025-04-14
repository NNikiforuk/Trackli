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
    let howManyToday: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), habits: filterUnfinished(), progress: countProgress(), howManyToday: countHowManyToday())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let items = filterUnfinished()
        let entry = SimpleEntry(date: Date(), habits: items, progress: countProgress(), howManyToday: countHowManyToday())
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let items = filterUnfinished()
        let entry = SimpleEntry(date: Date(), habits: items, progress: countProgress(), howManyToday: countHowManyToday())
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
    
    func countHowManyToday() -> Int {
        return filterTodaysHabits().count
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
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: Provider.Entry
    var habitsCount: Int { entry.habits.count }
    var percentText: String { "\(Int(entry.progress * 100))%" }
    var current: Double { entry.progress }
    var minValue: Double { 0 }
    var maxValue: Int { entry.howManyToday }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            if widgetFamily == .accessoryCircular {
                ZStack(alignment: .center) {
                    Circle()
                        .stroke(lineWidth: 10)
                        .opacity(0.2)
                        .foregroundStyle(.accent)
                    Text(percentText)
                        .foregroundStyle(.accent)
                    Circle()
                        .trim(from: 0.0, to: entry.progress)
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .foregroundStyle(.accent)
                        .rotationEffect(.degrees(-90))
                }
            } else {
                content
            }
        } else {
            content
        }
    }
    
    var content: some View {
        VStack {
            if habitsCount == 0 {
                Text(LocalizedStringKey("Good job!"))
                    .font(.body.bold())
                    .foregroundStyle(.noDataText)
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey("Still unchecked"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)
                        ForEach(entry.habits) { habit in
                            if let title = habit.title {
                                Text(title)
                                    .font(.caption.bold())
                                    .padding(.bottom, 1)
                            }
                        }
                        .foregroundStyle(.primaryText)
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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 5)
                    .frame(
                        width: 10,
                        height: geometry.size.height * CGFloat(min(progress, 1.0))
                    )
                    .foregroundColor(.progressBar)
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
    
    var supportedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [.systemSmall, .systemMedium]
        
        if #available(iOS 16.0, *) {
            families.append(contentsOf: [
                .accessoryInline,
                .accessoryCircular,
                .accessoryRectangular
            ])
        }
        
        return families
    }
    
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
        .supportedFamilies(supportedFamilies)
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
