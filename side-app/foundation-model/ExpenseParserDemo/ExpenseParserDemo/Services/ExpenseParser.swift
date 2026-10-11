//
//  ExpenseParser.swift
//  ExpenseParserDemo
//

import Foundation
import FoundationModels
import Observation

@Observable
final class ExpenseParser {
    var expenses: [Expense] = []
    var isParsing = false
    var errorMessage: String?

    var total: Int {
        expenses.reduce(0) { $0 + $1.amount }
    }

    func parse(_ note: String) async {
        errorMessage = nil
        isParsing = true
        defer { isParsing = false }

        do {
            try OnDeviceModel.checkAvailability()

            let session = LanguageModelSession(instructions: """
                You extract expenses from a short personal spending note.
                All amounts are in Indonesian Rupiah.
                Only list expenses that are written in the note. Do not invent new ones.
                """)

            // generating: memaksa jawaban mengikuti bentuk ExpenseList.
            // Sampling .greedy membuat hasil ekstraksi konsisten untuk input yang sama,
            // karena di sini yang dicari ketepatan, bukan variasi.
            let response = try await session.respond(
                to: note,
                generating: ExpenseList.self,
                options: GenerationOptions(sampling: .greedy)
            )
            expenses = response.content.expenses
        } catch {
            expenses = []
            errorMessage = OnDeviceError(error).localizedDescription
        }
    }
}
