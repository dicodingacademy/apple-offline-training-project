import SwiftUI

struct ContentView: View {
    @State private var generator = RecipeGenerator()
    @State private var ingredients = "eggs, onion, tomato"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("eggs, onion, tomato", text: $ingredients)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Bahan")
                } footer: {
                    Text("Pisahkan dengan koma, dalam Bahasa Inggris.")
                }

                Section {
                    Button {
                        Task { await generator.generate(from: ingredients) }
                    } label: {
                        HStack {
                            Label("Buat Resep", systemImage: "cloud")
                            Spacer()
                            if generator.isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(generator.isLoading)
                } footer: {
                    if let elapsed = generator.elapsed {
                        Text("Jawaban datang dalam \(elapsed, format: .number.precision(.fractionLength(1))) detik.")
                    }
                }

                if let errorMessage = generator.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }

                if let recipe = generator.recipe {
                    RecipeSections(recipe: recipe)
                }
            }
            .navigationTitle("Resep API")
        }
    }
}

struct RecipeSections: View {
    let recipe: RecipeData

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.recipeName)
                    .font(.headline)
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }

        Section("Nutrisi per porsi") {
            LabeledContent("Kalori", value: recipe.nutrition.calories)
            LabeledContent("Protein", value: recipe.nutrition.protein)
            LabeledContent("Karbohidrat", value: recipe.nutrition.carbohydrates)
            LabeledContent("Lemak", value: recipe.nutrition.fat)
            LabeledContent("Serat", value: recipe.nutrition.fiber)
        }

        Section("Bahan") {
            ForEach(recipe.ingredients, id: \.self) { Text($0) }
        }

        Section("Langkah") {
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                Text("\(index + 1). \(step)")
            }
        }
    }
}

#Preview {
    ContentView()
}
