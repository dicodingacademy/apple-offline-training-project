import Foundation

struct ExamPredictionInput {
    var isMale = true
    var ethnicity = "group A"
    var parentalEducationLevel = 2
    var hasStandardLunch = true
    var hasCompletedPreparationTest = false
    var readingScore = 70
    var writingScore = 70
}

struct ExamPredictionResult {
    let passed: Bool
    let probability: Double
}
