//
//  Expense.swift
//  ExpenseParserDemo
//

import Foundation
import FoundationModels

// @Generable membuat model bahasa tahu persis bentuk keluaran yang diminta.
// Hasilnya langsung berupa struct Swift, tanpa JSON yang perlu diurai sendiri.
@Generable
enum ExpenseCategory: CaseIterable {
    case food
    case transport
    case shopping
    case bills
    case entertainment
    case other
}

@Generable
struct Expense {
    @Guide(description: "Short name of the item or activity, for example Lunch or Gas")
    let name: String

    // "35k" bagi manusia jelas 35.000, tapi sulit ditangkap regex.
    // Guide ini mengajari model cara membacanya.
    @Guide(description: "Amount in Indonesian Rupiah as a whole number. 'k' or 'rb' means thousand, 'jt' means million. For example 35k is 35000.")
    let amount: Int

    let category: ExpenseCategory
}

@Generable
struct ExpenseList {
    @Guide(description: "Every expense mentioned in the note, in the same order")
    let expenses: [Expense]
}

extension ExpenseCategory {
    var label: String {
        switch self {
        case .food: return "Makanan"
        case .transport: return "Transportasi"
        case .shopping: return "Belanja"
        case .bills: return "Tagihan"
        case .entertainment: return "Hiburan"
        case .other: return "Lainnya"
        }
    }

    var symbol: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .bills: return "doc.text.fill"
        case .entertainment: return "gamecontroller.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}
