import SwiftUI
import PhotosUI

struct PhotoClassifierView: View {
    let classifier: DeskClassifierService
    let modelState: ContentView.ModelState

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var results: [ClassificationResult] = []
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    modelStatus

                    imagePreview

                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Pilih Foto Benda di Meja", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: classify) {
                        if isProcessing {
                            ProgressView().frame(maxWidth: .infinity).padding()
                        } else {
                            Text("Klasifikasikan").frame(maxWidth: .infinity).padding()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedImage == nil || isProcessing || modelState == .failed)

                    if !results.isEmpty {
                        ResultListView(results: results)
                    }
                }
                .padding()
            }
            .navigationTitle("Desk Classifier")
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        results = []
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var modelStatus: some View {
        switch modelState {
        case .loading:
            Label("Menyiapkan model Core AI…", systemImage: "hourglass")
                .font(.footnote)
                .foregroundStyle(.secondary)
        case .failed:
            Label("Model gagal dimuat. Cek log Xcode.", systemImage: "exclamationmark.triangle")
                .font(.footnote)
                .foregroundStyle(.red)
        case .ready:
            EmptyView()
        }
    }

    private var imagePreview: some View {
        Group {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 300)
                    .overlay { Text("Belum ada foto").foregroundStyle(.secondary) }
            }
        }
    }

    private func classify() {
        guard let cgImage = selectedImage?.uprightCGImage() else { return }
        isProcessing = true
        Task {
            results = await classifier.classify(cgImage)
            isProcessing = false
        }
    }
}

private extension UIImage {
    /// Menggambar ulang foto supaya orientasi EXIF (mis. foto potret dari
    /// kamera iPhone) sudah diterapkan ke piksel sebelum masuk model.
    func uprightCGImage() -> CGImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format)
            .image { _ in draw(at: .zero) }
            .cgImage
    }
}
