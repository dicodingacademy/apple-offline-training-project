import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var results: [ClassificationResult] = []
    @State private var isProcessing = false

    private let classifier = ImageClassifierService()

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
                        Label("Pilih Foto Buah/Sayur", systemImage: "photo.on.rectangle")
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
                    .disabled(selectedImage == nil || isProcessing)

                    if !results.isEmpty {
                        resultList
                    }
                }
                .padding()
            }
            .navigationTitle("Image Classifier Demo")
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

    private var resultList: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hasil Klasifikasi (Top 3)")
                .font(.headline)
                .padding(.bottom, 8)

            ForEach(results) { result in
                HStack {
                    Text(result.label.capitalized)
                    Spacer()
                    Text("\(Int(result.confidence * 100))%")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func classify() {
        guard let selectedImage else { return }
        isProcessing = true
        classifier.classify(image: selectedImage) { classified in
            results = classified
            isProcessing = false
        }
    }
}

#Preview {
    ContentView()
}
