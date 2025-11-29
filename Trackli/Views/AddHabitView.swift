//
//  AddHabitView.swift
//  Havit
//
//  Created by Natalia Nikiforuk on 27/03/2025.
//

import SwiftUI
import WidgetKit

struct AddHabitView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var newTitle = ""
    @State private var xDays = 2
    @State private var selectedWeekdays: Set<Weekday> = []
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @State private var everydayOptionSelected = false
    @State private var xDaysOptionSelected = false
    @State private var weekdaysOptionSelected = false
    
    @State private var showValidationAlert = false
    @State private var alertContent = ""
    @State private var isHabitCreated = false
    
    let calendar = Calendar.current
    
    var normalizedStartDate: Date {
        calendar.startOfDay(for: startDate)
    }
    var normalizedEndDate: Date {
        calendar.startOfDay(for: endDate)
    }
    var selectedTogglesCount: Int {
        [everydayOptionSelected, xDaysOptionSelected, weekdaysOptionSelected].filter{ $0 }.count
    }
    
    var body: some View {
        NavigationView {
            VStack {
                header
                timePickers
                newHabitTitle
                HabitToggles(xDaysOptionSelected: $xDaysOptionSelected, everydayOptionSelected: $everydayOptionSelected, weekdaysOptionSelected: $weekdaysOptionSelected, xDays: $xDays, selectedWeekdays: $selectedWeekdays, selectedTogglesCount: selectedTogglesCount)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bcg)
            .onTapGesture {
                hideKeyboard()
            }
            .alert(alertContent, isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.accentColor)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        addNewHabit()
                        
                        if let error = validationError() {
                            alertContent = error
                            showValidationAlert = true
                        } else {
                            save()
                        }
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    var header: some View {
        Text("Add new habit")
            .font(.title2)
            .fontWeight(.bold)
            .padding(.top, 20)
    }
    
    var newHabitTitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionSubheadline(title: "Title")
            newHabitTextField
        }
        .padding(.vertical, 20)
    }
    
    var newHabitTextField: some View {
        TextField("E.g. Flossing", text: $newTitle)
            .autocorrectionDisabled()
            .elementModifier()
    }
    
    var timePickers: some View {
        HStack {
            timePicker(title: "First day", startPicker: true)
            Spacer()
            timePicker(title: "Last day", startPicker: false)
        }
    }
    
    func validationError() -> String? {
        if normalizedStartDate > normalizedEndDate {
            return "The first day must be on or before the last day"
        }
        
        if newTitle.isEmpty {
            return "Title cannot be empty"
        }
        
        if selectedTogglesCount == 0 {
            return "No toggle selected"
        }
        
        if selectedTogglesCount > 1 {
            return "To many toggles selected"
        }
        
        if weekdaysOptionSelected && selectedWeekdays.isEmpty {
            return "Select specific day"
        }
        
        if weekdaysOptionSelected && !isHabitCreated {
            return "No matching weekday(s) found in the given range"
        }
        
        return nil
    }
    
    func timePicker(title: String, startPicker: Bool) -> some View {
        VStack(alignment: startPicker ? .leading : .trailing) {
            SectionSubheadline(title: title)
            DatePicker(
                "",
                selection: startPicker ? $startDate : $endDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
        .padding(.top, 30)
        .frame(maxWidth: .infinity, alignment: startPicker ? .leading : .trailing)
    }
    
    func addNewHabit() {
        let currentDate = normalizedStartDate
        
        if everydayOptionSelected {
            createHabitRepeatingEvery(days: 1, currentDate: currentDate)
        }
        
        if xDaysOptionSelected {
            createHabitRepeatingEvery(days: xDays, currentDate: currentDate)
        }
        
        if weekdaysOptionSelected {
            createHabitOnWeekdays(dayNames: selectedWeekdays, currentDate: currentDate)
        }
    }
    
    func createHabitRepeatingEvery(days: Int, currentDate: Date) {
        var date = currentDate
        
        while date <= normalizedEndDate {
            let newHabit = Habit(context: viewContext)
            
            newHabit.id = UUID()
            newHabit.title = newTitle
            newHabit.isCompleted = false
            newHabit.startDate = date
            
            if let nextDate = calendar.date(byAdding: .day, value: days, to: date) {
                date = nextDate
            } else {
                break
            }
        }
    }
    
    func createHabitOnWeekdays(dayNames: Set<Weekday>, currentDate: Date) {
        var date = currentDate
        
        while date <= normalizedEndDate {
            guard let weekday = Weekday.from(date: date) else {
                continue
            }
            
            if dayNames.contains(weekday) {
                isHabitCreated = true
                let newHabit = Habit(context: viewContext)
                newHabit.id = UUID()
                newHabit.title = newTitle
                newHabit.isCompleted = false
                newHabit.startDate = date
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else {
                break
            }
            date = nextDate
        }
    }
    
    func save() {
        do {
            try viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
            dismiss()
            
        } catch {
            print("Błąd zapisywania habitów: \(error)")
        }
    }
}

struct HabitToggles: View {
    @Binding var xDaysOptionSelected: Bool
    @Binding var everydayOptionSelected: Bool
    @Binding var weekdaysOptionSelected: Bool
    @Binding var xDays: Int
    @Binding var selectedWeekdays: Set<Weekday>
    
    var selectedTogglesCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionSubheadline(title: "Choose one tracking format")
            VStack(spacing: 10) {
                everydayToggle
                everyXDays
                selectSpecificDays
            }
        }
    }
    
    var everydayToggle: some View {
        NewHabitToggle(selectedOption: $everydayOptionSelected, title: "Everyday")
    }
    
    var everyXDaysToggleTitle: String {
        if xDaysOptionSelected {
            return String(format: "Title for habit toggle when a specific number of days is selected", xDays)
        } else {
            return "Title for habit toggle when a default value is used"
        }
    }
    
    var everyXDays: some View {
        VStack {
            NewHabitToggle(selectedOption: $xDaysOptionSelected, title: everyXDaysToggleTitle)
            
            if xDaysOptionSelected {
                Stepper("", value: $xDays, in: 2...14)
                    .foregroundStyle(.primaryText)
                    .labelsHidden()
            }
        }
    }
    
    var selectSpecificDays: some View {
        VStack {
            NewHabitToggle(selectedOption: $weekdaysOptionSelected, title: "Select day(s) of the week")
            
            if weekdaysOptionSelected {
                HStack(spacing: 8) {
                    ForEach(Weekday.allCases) { day in
                        Button(action: {
                            if selectedWeekdays.contains(day) {
                                selectedWeekdays.remove(day)
                            } else {
                                selectedWeekdays.insert(day)
                            }
                        }) {
                            Text(day.rawValue)
                                .font(.subheadline.bold())
                                .frame(width: 44, height: 36)
                                .background(selectedWeekdays.contains(day) ? .accent.opacity(0.4) : .customPrimary.opacity(0.5))
                                .foregroundColor(.whiteText)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

struct NewHabitToggle: View {
    @Binding var selectedOption: Bool
    let title: String
    
    var body: some View {
        Toggle(isOn: $selectedOption) {
            Text(title)
                .fontWeight(.bold)
        }
        .tint(.accent)
        .elementModifier()
        .onChange(of: selectedOption) { _ in
            hideKeyboard()
        }
    }
}

struct SectionSubheadline: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}

#Preview {
    AddHabitView()
}
