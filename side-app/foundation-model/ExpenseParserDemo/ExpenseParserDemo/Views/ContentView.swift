import SwiftUI

struct ContentView: View {
    @State private var parser = ExpenseParser()
    @State private var note = "lunch 35k, gas 50k, coffee with friends 18k, paid the electricity bill 250k, movie ticket 45k"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                } header: {
                    Text("Catatan pengeluaran")
                } footer: {
                    Text("Tulis bebas dalam Bahasa Inggris, misalnya \"lunch 35k, gas 50k\".")
                }

                Section {
                    Button {
                        Task { await parser.parse(note) }
                    } label: {
                        HStack {
                            Text("Catat")
                            Spacer()
                            if parser.isParsing {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || parser.isParsing)
                }

                if let errorMessage = parser.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }

                if !parser.expenses.isEmpty {
                    Section("Transaksi") {
                        ForEach(Array(parser.expenses.enumerated()), id: \.offset) { _, expense in
                            ExpenseRow(expense: expense)
                        }
                    }

                    Section {
                        HStack {
                            Text("Total")
                                .bold()
                            Spacer()
                            Text(parser.total.rupiah)
                                .bold()
                                .monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle("Catat Pengeluaran")
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.symbol)
                .foregroundStyle(.tint)
                .frame(width: 28)
            VStack(alignment: .leading) {
                Text(expense.name)
                Text(expense.category.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(expense.amount.rupiah)
                .monospacedDigit()
        }
    }
}

extension Int {
    var rupiah: String {
        formatted(.currency(code: "IDR").precision(.fractionLength(0)).locale(Locale(identifier: "id_ID")))
    }
}

#Preview {
    ContentView()
}
