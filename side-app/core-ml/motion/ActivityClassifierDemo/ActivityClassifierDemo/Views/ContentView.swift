import SwiftUI

struct ContentView: View {
    @State private var manager = ActivityClassifierManager()
    private let sampleWindow = 100

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                if let label = manager.currentLabel {
                    VStack(spacing: 8) {
                        Text(label.capitalized)
                            .font(.system(size: 42, weight: .bold))
                        Text("Confidence: \(Int(manager.confidence * 100))%")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Belum ada prediksi")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: Double(manager.sampleProgress), total: Double(sampleWindow))
                    .padding(.horizontal, 40)
                Text("Mengumpulkan sampel: \(manager.sampleProgress)/\(sampleWindow)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Pegang & gerakkan iPhone (jalan, duduk, berdiri, berbaring) untuk melihat klasifikasi berubah.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Button(manager.isRunning ? "Stop" : "Mulai Deteksi") {
                    manager.isRunning ? manager.stopSession() : manager.startSession()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 32)
            }
            .navigationTitle("Activity Classifier Demo")
            .alert("Accelerometer Tidak Tersedia", isPresented: $manager.accelerometerUnavailable) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Demo ini butuh perangkat fisik dengan accelerometer (tidak tersedia di Simulator).")
            }
        }
    }
}

#Preview {
    ContentView()
}
