import SwiftUI

struct ContentView: View {
    @State private var items: [String] = PantryStore.items
    @State private var newItem = ""
    @State private var recipe: Recipe?
    @State private var errorMessage: String?
    @State private var isGenerating = false

    var body: some View {
        NavigationStack {
            List {
                Section("Stok Bahan") {
                    if items.isEmpty {
                        Text("Belum ada bahan.").foregroundStyle(.secondary)
                    } else {
                        ForEach(items, id: \.self) { Text($0) }
                    }
                    HStack {
                        TextField("Tambah bahan, mis. Eggs", text: $newItem)
                            .onSubmit(add)
                        Button("Tambah", action: add)
                            .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section {
                    Button(action: suggest) {
                        if isGenerating {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Label("Sarankan Resep", systemImage: "fork.knife")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isGenerating)
                } footer: {
                    Text("Aksi yang sama bisa dipanggil tanpa membuka app: ucapkan \"Suggest a recipe with Pantry Chef\" ke Siri, atau pakai aksi Sarankan Resep di app Shortcuts.")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }

                if let recipe {
                    Section("Resep") {
                        RecipeCard(recipe: recipe)
                            .listRowInsets(EdgeInsets())
                    }
                }
            }
            .navigationTitle("Pantry Chef")
            .toolbar {
                Button("Muat Ulang") { items = PantryStore.items }
                Button("Kosongkan") {
                    PantryStore.clear()
                    items = []
                    recipe = nil
                }
            }
        }
    }

    private func add() {
        PantryStore.add(newItem)
        items = PantryStore.items
        newItem = ""
    }

    private func suggest() {
        errorMessage = nil
        isGenerating = true
        Task {
            do {
                recipe = try await RecipeGenerator.suggest(from: PantryStore.items)
            } catch {
                recipe = nil
                errorMessage = error.localizedDescription
            }
            isGenerating = false
        }
    }
}

#Preview { ContentView() }
