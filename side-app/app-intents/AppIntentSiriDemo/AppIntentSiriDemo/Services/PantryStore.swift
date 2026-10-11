//
//  PantryStore.swift
//  AppIntentSiriDemo
//

import Foundation

// Penyimpanan sederhana lewat UserDefaults. Dipakai bersama oleh tampilan
// dan oleh App Intent, karena intent bisa berjalan saat app tidak dibuka.
nonisolated enum PantryStore {
    private static let key = "pantry.items"

    static var items: [String] {
        get { UserDefaults.standard.stringArray(forKey: key) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    @discardableResult
    static func add(_ item: String) -> Int {
        let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items.count }
        items.append(trimmed)
        return items.count
    }

    static func clear() { items = [] }
}
