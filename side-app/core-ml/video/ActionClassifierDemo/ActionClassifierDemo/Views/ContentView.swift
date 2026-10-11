import SwiftUI

struct ContentView: View {
    @State private var manager = ActionClassifierManager()
    private let windowSize = 450

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CameraPreviewView(previewLayer: manager.previewLayer)
                    .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 12) {
                    if let label = manager.currentLabel {
                        VStack(spacing: 4) {
                            Text(label)
                                .font(.largeTitle).bold()
                                .foregroundStyle(.white)
                            Text("Confidence: \(Int(manager.confidence * 100))%")
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding()
                        .background(.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    ProgressView(value: Double(manager.bufferProgress), total: Double(windowSize))
                        .tint(.white)
                    Text("Mengumpulkan pose: \(manager.bufferProgress)/\(windowSize) frame")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
                .padding()
                .background(.black.opacity(0.4))
            }
            .navigationTitle("Action Classifier Demo")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { manager.startSession() }
            .onDisappear { manager.stopSession() }
            .alert("Akses Kamera Ditolak", isPresented: Bindable(manager).permissionDenied) {
                Button("Buka Pengaturan") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                Button("Kembali", role: .cancel) {}
            } message: {
                Text("Demo ini butuh akses kamera untuk mendeteksi aksi tubuh secara real-time.")
            }
        }
    }
}

#Preview {
    ContentView()
}
