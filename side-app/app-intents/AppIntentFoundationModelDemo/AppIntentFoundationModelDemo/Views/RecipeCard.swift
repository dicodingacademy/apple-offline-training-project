import SwiftUI

// Dipakai di dua tempat: snippet hasil SuggestRecipeIntent (Siri / Shortcuts)
// dan kartu resep di dalam app. Snippet tidak bisa di-scroll, jadi isinya
// dibuat ringkas.
struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(recipe.title)
                    .font(.headline)
                Spacer()
                Label("\(recipe.minutes) mnt", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Bahan")
                .font(.subheadline).bold()
            ForEach(recipe.ingredients, id: \.self) { item in
                Text("• \(item)").font(.footnote)
            }

            Text("Langkah")
                .font(.subheadline).bold()
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                Text("\(index + 1). \(step)").font(.footnote)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}
