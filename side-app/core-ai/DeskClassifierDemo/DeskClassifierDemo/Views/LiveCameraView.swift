import SwiftUI

struct LiveCameraView: View {
    @State private var manager: LiveCameraManager

    init(classifier: DeskClassifierService) {
        _manager = State(initialValue: LiveCameraManager(classifier: classifier))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CameraPreviewView(previewLayer: manager.previewLayer)
                    .ignoresSafeArea(edges: .top)

                // Bingkai persegi = area yang benar-benar dilihat model (center-crop).
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.8), lineWidth: 2)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(32)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)

                overlay
                    .padding()
            }
            .navigationTitle("Kamera Live")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { manager.startSession() }
            .onDisappear { manager.stopSession() }
            .alert("Akses Kamera Ditolak", isPresented: $manager.permissionDenied) {
                Button("Buka Pengaturan") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                Button("Kembali", role: .cancel) {}
            } message: {
                Text("Demo ini butuh akses kamera untuk mengenali benda di meja secara real-time.")
            }
        }
    }

    @ViewBuilder
    private var overlay: some View {
        if let top = manager.results.first {
            VStack(spacing: 4) {
                Text(top.displayName)
                    .font(.largeTitle).bold()
                Text("\(top.label) · \(Int(top.confidence * 100))%")
                    .foregroundStyle(.white.opacity(0.8))
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.black.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Text(manager.isRunning ? "Arahkan kamera ke benda di meja" : "Kamera belum aktif (butuh perangkat fisik)")
                .font(.callout)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.black.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
