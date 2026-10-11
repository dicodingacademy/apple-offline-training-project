import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var scores: [GenreScore] = []
    @State private var isProcessing = false

    private let classifier = MultiLabelClassifierService()

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
                        Label("Pilih Poster Film", systemImage: "photo.on.rectangle")
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
                            Text("Deteksi Genre").frame(maxWidth: .infinity).padding()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedImage == nil || isProcessing)

                    if !scores.isEmpty {
                        scoreList
                    }
                }
                .padding()
            }
            .navigationTitle("Multi-Label Classifier Demo")
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        scores = []
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

    private var scoreList: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Genre (ambang deteksi 50%)")
                .font(.headline)
                .padding(.bottom, 8)

            ForEach(scores) { score in
                HStack {
                    Image(systemName: score.isDetected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(score.isDetected ? .green : .secondary)
                    Text(score.label)
                    Spacer()
                    Text("\(Int(score.probability * 100))%")
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
            scores = classified
            isProcessing = false
        }
    }
}

#Preview {
    ContentView()
}
