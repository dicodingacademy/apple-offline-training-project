import SwiftUI

struct ContentView: View {
    @State private var input = PerformanceInput()
    @State private var predictedScore: Double?

    private let predictor = PerformancePredictorService()

    var body: some View {
        NavigationStack {
            Form {
                Section("Kebiasaan Belajar") {
                    Stepper("Jam Belajar/Hari: \(input.hoursStudied)", value: $input.hoursStudied, in: 0...12)
                    Stepper("Skor Sebelumnya: \(input.previousScores)", value: $input.previousScores, in: 0...100, step: 5)
                    Toggle("Ikut Ekstrakurikuler", isOn: $input.hasExtracurricular)
                    Stepper("Jam Tidur/Hari: \(input.sleepHours)", value: $input.sleepHours, in: 0...12)
                    Stepper("Soal Latihan Dikerjakan: \(input.papersPracticed)", value: $input.papersPracticed, in: 0...20)
                }

                Section {
                    Button("Prediksi Performance Index") { predict() }
                }

                if let predictedScore {
                    Section("Hasil Prediksi") {
                        Text("Performance Index: \(String(format: "%.1f", predictedScore))")
                            .bold()
                    }
                }
            }
            .navigationTitle("Performance Predictor (Prev Score) Demo")
        }
    }

    private func predict() {
        predictedScore = predictor.predict(input)
    }
}

#Preview {
    ContentView()
}
