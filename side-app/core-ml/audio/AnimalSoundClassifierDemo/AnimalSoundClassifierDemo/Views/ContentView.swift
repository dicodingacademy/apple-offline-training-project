import SwiftUI

struct ContentView: View {
    @State private var manager = AnimalSoundClassifierManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: manager.isRunning ? "waveform.circle.fill" : "waveform.circle")
                    .font(.system(size: 80))
                    .foregroundStyle(manager.isRunning ? .green : .secondary)
                    .symbolEffect(.pulse, isActive: manager.isRunning)

                if let label = manager.currentLabel {
                    VStack(spacing: 8) {
                        Text(label)
                            .font(.system(size: 36, weight: .bold))
                        Text("Confidence: \(Int(manager.confidence * 100))%")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(manager.isRunning ? "Mendengarkan..." : "Belum ada prediksi")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Putar suara hewan (video/rekaman) di dekat mikrofon untuk melihat klasifikasi.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Button(manager.isRunning ? "Stop" : "Mulai Dengarkan") {
                    manager.isRunning ? manager.stopSession() : manager.startSession()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 32)
            }
            .navigationTitle("Animal Sound Classifier Demo")
            .alert("Akses Mikrofon Ditolak", isPresented: $manager.permissionDenied) {
                Button("Buka Pengaturan") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                Button("Kembali", role: .cancel) {}
            } message: {
                Text("Demo ini butuh akses mikrofon untuk mendengarkan & mengklasifikasikan suara.")
            }
        }
    }
}

#Preview {
    ContentView()
}
