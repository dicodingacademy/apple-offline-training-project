import CoreML
import Foundation

/// Membungkus model CoreML `LinearRegression.mlmodel` (tabular regressor hasil
/// training CreateML) yang memprediksi "Performance Index" siswa dari
/// kebiasaan belajar. Dipanggil langsung lewat `MLModel` +
/// `MLDictionaryFeatureProvider`, tanpa Vision framework.
final class PerformancePredictorService {
    private var model: MLModel?

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "LinearRegression", withExtension: "mlmodelc") else {
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
