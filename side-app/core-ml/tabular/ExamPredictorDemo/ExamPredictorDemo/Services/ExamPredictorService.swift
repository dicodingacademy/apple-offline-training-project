import CoreML
import Foundation

/// Membungkus model CoreML `LogisticRegression.mlmodel` (tabular classifier
/// hasil training CreateML dari dataset performa ujian siswa). Model ini
/// BUKAN model Vision — dipanggil langsung lewat `MLModel` dengan
/// `MLDictionaryFeatureProvider`, sesuai cara integrasi model tabular pada
/// umumnya.
///
/// Nilai kategori string HARUS persis sama dengan yang dipelajari model saat
/// training (case-sensitive): "yes"/"no" untuk field boolean, "group A".."group E"
/// untuk ethnicity.
final class ExamPredictorService {
    private var model: MLModel?

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "LogisticRegression", withExtension: "mlmodelc") else {
                print("ExamPredictorService: model tidak ditemukan di bundle")
                return
            }
            model = try MLModel(contentsOf: url)
        } catch {
            print("ExamPredictorService: gagal load model — \(error)")
        }
    }

    func predict(_ input: ExamPredictionInput) -> ExamPredictionResult? {
        guard let model else { return nil }

        do {
            let features: [String: Any] = [
                "is_male": input.isMale ? "yes" : "no",
                "ethnicity": input.ethnicity,
                "parental_level_of_education": Int64(input.parentalEducationLevel),
                "has_standard_lunch": input.hasStandardLunch ? "yes" : "no",
                "has_completed_preparation_test": input.hasCompletedPreparationTest ? "yes" : "no",
                "reading_score": Int64(input.readingScore),
                "writing_score": Int64(input.writingScore)
            ]
            let provider = try MLDictionaryFeatureProvider(dictionary: features)
            let output = try model.prediction(from: provider)

            guard let label = output.featureValue(for: "has_passed_math_exam")?.stringValue else {
                return nil
            }
            let probability = output
                .featureValue(for: "has_passed_math_examProbability")?
                .dictionaryValue[label]?
                .doubleValue ?? 0

            return ExamPredictionResult(passed: label == "passed", probability: probability)
        } catch {
            print("ExamPredictorService: prediction error — \(error)")
            return nil
        }
    }
}
