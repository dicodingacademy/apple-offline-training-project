import SwiftUI

struct ContentView: View {
    @State private var input = ExamPredictionInput()
    @State private var result: ExamPredictionResult?

    private let ethnicityOptions = ["group A", "group B", "group C", "group D", "group E"]
    private let predictor = ExamPredictorService()

    var body: some View {
        NavigationStack {
            Form {
                Section("Data Siswa") {
                    Toggle("Laki-laki", isOn: $input.isMale)

                    Picker("Kelompok Etnis", selection: $input.ethnicity) {
                        ForEach(ethnicityOptions, id: \.self) { Text($0) }
                    }

                    Stepper("Level Pendidikan Orang Tua: \(input.parentalEducationLevel)",
                            value: $input.parentalEducationLevel, in: 0...5)

                    Toggle("Lunch Standar (bukan gratis/subsidi)", isOn: $input.hasStandardLunch)
                    Toggle("Sudah Ikut Kelas Persiapan Ujian", isOn: $input.hasCompletedPreparationTest)
                }

                Section("Skor") {
                    Stepper("Reading Score: \(input.readingScore)", value: $input.readingScore, in: 0...100, step: 5)
                    Stepper("Writing Score: \(input.writingScore)", value: $input.writingScore, in: 0...100, step: 5)
                }

                Section {
                    Button("Prediksi") { predict() }
                }

                if let result {
                    Section("Hasil Prediksi") {
                        HStack {
                            Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(result.passed ? .green : .red)
                            Text(result.passed ? "Diprediksi LULUS" : "Diprediksi TIDAK LULUS")
                                .bold()
                        }
                        Text("Confidence: \(Int(result.probability * 100))%")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Exam Predictor Demo")
        }
    }

    private func predict() {
        result = predictor.predict(input)
    }
}

#Preview {
    ContentView()
}
