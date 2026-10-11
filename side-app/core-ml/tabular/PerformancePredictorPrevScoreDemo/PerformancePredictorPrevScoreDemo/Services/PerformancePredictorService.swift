import CoreML
import Foundation

/// Membungkus model CoreML `LinearRegressionPrevScore.mlmodel` — varian dari
/// LinearRegression yang menambahkan fitur "Previous Scores" untuk prediksi
/// "Performance Index" yang lebih akurat. Dipanggil langsung lewat `MLModel` +
/// `MLDictionaryFeatureProvider`, tanpa Vision framework.
final class PerformancePredictorService {
    private var model: MLModel?

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "LinearRegressionPrevScore", withExtension: "mlmodelc") else {
                print("PerformancePredictorService: model tidak ditemukan di bundle")
                return
            }
            model = try MLModel(contentsOf: url)
        } catch {
            print("PerformancePredictorService: gagal load model — \(error)")
        }
    }

    func predict(_ input: PerformanceInput) -> Double? {
        guard let model else { return nil }

        do {
            let features: [String: Any] = [
                "Hours Studied": Int64(input.hoursStudied),
                "Previous Scores": Int64(input.previousScores),
                "Extracurricular Activities": input.hasExtracurricular ? "Yes" : "No",
                "Sleep Hours": Int64(input.sleepHours),
                "Sample Question Papers Practiced": Int64(input.papersPracticed)
            ]
            let provider = try MLDictionaryFeatureProvider(dictionary: features)
            let output = try model.prediction(from: provider)
            return output.featureValue(for: "Performance Index")?.doubleValue
        } catch {
            print("PerformancePredictorService: prediction error — \(error)")
            return nil
        }
    }
}
