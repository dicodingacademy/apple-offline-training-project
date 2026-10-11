import SwiftUI

struct ContentView: View {
    @State private var sampleRecipes: [String] = []
    @State private var likedRecipes: Set<String> = []
    @State private var recommendationCount = 5
    @State private var recommendations: [RecipeRecommendation] = []
    @State private var searchText = ""

    private let recommender = RecipeRecommenderService()

    private var filteredRecipes: [String] {
        guard !searchText.isEmpty else { return sampleRecipes }
        return sampleRecipes.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Stepper("Jumlah rekomendasi: \(recommendationCount)", value: $recommendationCount, in: 1...10)
                    Button("Rekomendasikan Resep") { recommend() }
                        .disabled(likedRecipes.isEmpty)
                }

                if !recommendations.isEmpty {
                    Section("Rekomendasi untuk Anda") {
                        ForEach(recommendations) { rec in
                            HStack {
                                Text(rec.name.capitalized)
                                Spacer()
                                Text(String(format: "%.2f", rec.score))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Pilih resep yang Anda suka (\(likedRecipes.count) dipilih)") {
                    ForEach(filteredRecipes, id: \.self) { recipe in
                        Button {
                            toggle(recipe)
                        } label: {
                            HStack {
                                Text(recipe.capitalized)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if likedRecipes.contains(recipe) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Cari resep")
            .navigationTitle("Recipe Recommender Demo")
            .onAppear(perform: loadSampleRecipes)
        }
    }

    private func toggle(_ recipe: String) {
        if likedRecipes.contains(recipe) {
            likedRecipes.remove(recipe)
        } else {
            likedRecipes.insert(recipe)
        }
    }

    private func recommend() {
        recommendations = recommender.recommend(likedItems: Array(likedRecipes), count: recommendationCount)
    }

    private func loadSampleRecipes() {
        guard let url = Bundle.main.url(forResource: "SampleRecipes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let names = try? JSONDecoder().decode([String].self, from: data) else {
            return
        }
        sampleRecipes = names
    }
}

#Preview {
    ContentView()
}
