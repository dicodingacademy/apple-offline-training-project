import CoreML
import Foundation

/// Membungkus model CoreML `RecipeRecommender.mlmodel` (asli: "MyRecommender 1",
/// tipe `itemSimilarityRecommender` hasil training CreateML dari ~7.845 nama
/// resep). Model ini BUKAN model Vision — dipanggil langsung lewat `MLModel`
/// dengan `MLDictionaryFeatureProvider`, tanpa Vision framework sama sekali.
///
/// Input `items` berisi resep yang "disukai" user (nama resep harus persis
/// sama dengan salah satu item yang dikenal model saat training — lihat
/// Resources/SampleRecipes.json untuk daftar contoh nama yang valid).
final class RecipeRecommenderService {
    private var model: MLModel?

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "RecipeRecommender", withExtension: "mlmodelc") else {
                print("RecipeRecommenderService: model tidak ditemukan di bundle")
                return
            }
            model = try MLModel(contentsOf: url)
        } catch {
            print("RecipeRecommenderService: gagal load model — \(error)")
        }
    }

    func recommend(likedItems: [String], count: Int) -> [RecipeRecommendation] {
        guard let model, !likedItems.isEmpty else { return [] }

        do {
            let itemsDict: [AnyHashable: NSNumber] = Dictionary(
                uniqueKeysWithValues: likedItems.map { ($0, NSNumber(value: 1.0)) }
            )
            let itemsValue = try MLFeatureValue(dictionary: itemsDict)

            let provider = try MLDictionaryFeatureProvider(dictionary: [
                "items": itemsValue,
                "k": Int64(count)
            ])

            let output = try model.prediction(from: provider)

            guard let recommendationNames = output.featureValue(for: "recommendations")?.sequenceValue?.stringValues else {
                return []
            }
            let scoresDict = output.featureValue(for: "scores")?.dictionaryValue

            return recommendationNames.map { name in
                let score = scoresDict?[name]?.doubleValue ?? 0
                return RecipeRecommendation(name: name, score: score)
            }
        } catch {
            print("RecipeRecommenderService: prediction error — \(error)")
            return []
        }
    }
}
