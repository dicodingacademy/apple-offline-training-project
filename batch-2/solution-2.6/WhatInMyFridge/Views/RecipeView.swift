import SwiftUI

struct RecipeView: View {
    let ingredients: [String]

    @State private var viewModel = RecipeViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                detectedIngredientsSection
                generateButton
                contentSection
            }
            .padding()
        }
        .navigationTitle("Resep & Nutrisi")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var detectedIngredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Bahan Terdeteksi", systemImage: "cart.fill")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(ingredients, id: \.self) { ingredient in
                    Text(ingredient.capitalized)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var generateButton: some View {
        Button {
            Task { await viewModel.generateRecipe(for: ingredients) }
        } label: {
            Group {
                if viewModel.isLoading {
                    HStack {
                        ProgressView().tint(.white)
                        Text("Membuat resep...").foregroundStyle(.white)
                    }
                } else {
                    Label("Buat Resep & Nutrisi", systemImage: "wand.and.stars")
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.isLoading ? Color.gray : Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(viewModel.isLoading)
    }

    @ViewBuilder
    private var contentSection: some View {
        if let error = viewModel.errorMessage {
            ErrorView(message: error) {
                Task { await viewModel.generateRecipe(for: ingredients) }
            }
        } else if let recipe = viewModel.recipe {
            RecipeDetailView(recipe: recipe)
        }
    }
}

// MARK: - RecipeDetailView

struct RecipeDetailView: View {
    let recipe: RecipeData

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.recipeName)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Nutrisi
            nutritionSection

            Divider()

            // Bahan-bahan
            listSection(title: "Bahan-bahan", icon: "list.bullet", items: recipe.ingredients)

            Divider()

            // Langkah memasak
            stepsSection
        }
    }

    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Informasi Nutrisi (per porsi)", systemImage: "heart.text.square")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                NutritionCard(title: "Kalori", value: recipe.nutrition.calories, icon: "flame.fill", color: .red)
                NutritionCard(title: "Protein", value: recipe.nutrition.protein, icon: "bolt.fill", color: .blue)
                NutritionCard(title: "Karbohidrat", value: recipe.nutrition.carbohydrates, icon: "leaf.fill", color: .green)
                NutritionCard(title: "Lemak", value: recipe.nutrition.fat, icon: "drop.fill", color: .yellow)
                NutritionCard(title: "Serat", value: recipe.nutrition.fiber, icon: "circle.grid.cross.fill", color: .purple)
            }
        }
    }

    private func listSection(title: String, icon: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon).font(.headline)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .padding(.top, 6)
                        .foregroundStyle(.secondary)
                    Text(item).font(.subheadline)
                }
            }
        }
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Cara Memasak", systemImage: "frying.pan").font(.headline)
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(.orange)
                        .clipShape(Circle())

                    Text(step)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - NutritionCard

struct NutritionCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(.headline).fontWeight(.semibold)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - ErrorView

struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            Button("Coba Lagi", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - FlowLayout (chip layout)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > width, rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    RecipeView(ingredients: ["Apple"] )
}
