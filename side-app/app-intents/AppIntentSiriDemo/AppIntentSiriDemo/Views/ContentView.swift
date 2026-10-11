import SwiftUI

struct ContentView: View {
    @State private var items: [String] = PantryStore.items

    var body: some View {
        NavigationStack {
            List {
                Section("Stok Bahan") {
                    if items.isEmpty {
                        Text("Belum ada bahan.").foregroundStyle(.secondary)
                    } else {
                        ForEach(items, id: \.self) { Text($0) }
                    }
                }

                Section {
                    Text("Tambahkan bahan lewat Siri atau app Shortcuts, lalu tekan Muat Ulang di sini.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Pantry")
            .toolbar {
                Button("Muat Ulang") { items = PantryStore.items }
                Button("Kosongkan") { PantryStore.clear(); items = [] }
            }
        }
    }
}

#Preview { ContentView() }
