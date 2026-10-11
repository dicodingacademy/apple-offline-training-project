import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var result: HandPoseResult?
    @State private var isProcessing = false

    private let classifier = HandPoseClassifierService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    imagePreview

                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Pilih Foto Tangan", systemImage: "photo.on.rectangle")
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
                            Text("Klasifikasikan Pose").frame(maxWidth: .infinity).padding()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedImage == nil || isProcessing)

                    if let result {
                        VStack(spacing: 4) {
                            Text(result.label)
                                .font(.largeTitle).bold()
                            Text("Confidence: \(Int(result.confidence * 100))%")
                                .foregroundStyle(.secondary)
                        }
                    } else if selectedImage != nil, !isProcessing {
                        Text("Tidak ada tangan terdeteksi pada foto ini.")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Hand Pose Classifier Demo")
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        result = nil
                    }
                }
            }
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
                    .overlay { Text("Belum ada foto (foto tangan membentuk isyarat)").foregroundStyle(.secondary) }
            }
        }
    }

    private func classify() {
        guard let selectedImage else { return }
        isProcessing = true
        result = nil
        classifier.classify(image: selectedImage) { classified in
            result = classified
            isProcessing = false
        }
    }
}

#Preview {
    ContentView()
}
