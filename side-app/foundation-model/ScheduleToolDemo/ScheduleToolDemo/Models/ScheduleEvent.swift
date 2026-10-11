//
//  ScheduleEvent.swift
//  ScheduleToolDemo
//

import Foundation

// Data dummy supaya demo tidak perlu izin akses kalender (EventKit).
// nonisolated karena data ini dibaca dari dalam Tool, yang berjalan di luar main actor.
nonisolated struct ScheduleEvent: Identifiable, Sendable {
    let id = UUID()
    let day: String
    let start: String
    let end: String
    let title: String
}

nonisolated enum SampleSchedule {
    static let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    static let events: [ScheduleEvent] = [
        ScheduleEvent(day: "Monday", start: "08:00", end: "10:00", title: "iOS Development class"),
        ScheduleEvent(day: "Monday", start: "13:00", end: "14:00", title: "Team meeting"),
        ScheduleEvent(day: "Tuesday", start: "09:00", end: "12:00", title: "Machine Learning lab"),
        ScheduleEvent(day: "Wednesday", start: "15:00", end: "16:00", title: "Consultation with lecturer"),
        ScheduleEvent(day: "Thursday", start: "08:00", end: "09:30", title: "UI/UX class"),
        ScheduleEvent(day: "Thursday", start: "10:00", end: "12:00", title: "Group project"),
        ScheduleEvent(day: "Thursday", start: "16:00", end: "17:30", title: "Badminton"),
        ScheduleEvent(day: "Friday", start: "13:30", end: "15:00", title: "Final project presentation"),
        ScheduleEvent(day: "Saturday", start: "10:00", end: "12:00", title: "Coffee with friends"),
    ]

    static func events(on day: String) -> [ScheduleEvent] {
        events.filter { $0.day.caseInsensitiveCompare(day) == .orderedSame }
    }
}
