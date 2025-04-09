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
    let itemCount: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let itemCount = (try? getData().count) ?? 0
        return SimpleEntry(date: Date(), itemCount: itemCount)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        do {
            let items = try getData()
            let entry = SimpleEntry(date: Date(), itemCount: items.count)
            
            completion(entry)
        } catch {
            print(error)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let items = try getData()
            let entry = SimpleEntry(date: Date(), itemCount: items.count)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }catch {
            print(error)
        }
    }
    
    private func getData() throws -> [Habit] {
        let context = PersistenceController.shared.container.viewContext
        let request = Habit.fetchRequest()
        let result = try context.fetch(request)
        
        return result
    }
}

struct CustomWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.itemCount, format: .number)
    }
}

struct CustomWidget: Widget {
    let kind: String = "CustomWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CustomWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
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

#Preview(as: .systemSmall) {
    CustomWidget()
} timeline: {
    SimpleEntry(date: .now, itemCount: 4)
}
