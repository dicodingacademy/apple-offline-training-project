import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var preparedImage: UIImage?
    @State private var detections: [DetectionResult] = []
    @State private var isProcessing = false

    private let detector = FoodObjectDetectorService()

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
                        Label("Pilih Foto Bahan Makanan", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: detect) {
                        if isProcessing {
                            ProgressView().frame(maxWidth: .infinity).padding()
                        } else {
                            Text("Deteksi Objek").frame(maxWidth: .infinity).padding()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(preparedImage == nil || isProcessing)

                    if !detections.isEmpty {
                        resultList
                    }
                }
                .padding()
            }
            .navigationTitle("Food Object Detector Demo")
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        preparedImage = image.centerCroppedSquare()
                        detections = []
                    }
                }
            }
        }
    }

    private var imagePreview: some View {
        GeometryReader { geo in
            let side = geo.size.width
            ZStack(alignment: .topLeading) {
                if let preparedImage {
                    Image(uiImage: preparedImage)
                        .resizable()
                        .frame(width: side, height: side)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: side, height: side)
                        .overlay { Text("Belum ada foto").foregroundStyle(.secondary) }
                }

                ForEach(detections) { detection in
                    boundingBoxView(detection: detection, side: side)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func boundingBoxView(detection: DetectionResult, side: CGFloat) -> some View {
        let box = detection.boundingBox
        let rect = CGRect(
            x: box.minX * side,
            y: (1 - box.maxY) * side,
            width: box.width * side,
            height: box.height * side
        )

        return ZStack(alignment: .topLeading) {
            Rectangle()
                .stroke(Color.green, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)

            Text("\(detection.label) \(Int(detection.confidence * 100))%")
                .font(.caption2).bold()
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .background(.black.opacity(0.7))
                .offset(y: -18)
        }
        .position(x: rect.midX, y: rect.midY)
    }

    private var resultList: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Objek Terdeteksi")
                .font(.headline)
                .padding(.bottom, 8)

            ForEach(detections) { detection in
                HStack {
                    Text(detection.label)
                    Spacer()
                    Text("\(Int(detection.confidence * 100))%")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func detect() {
        guard let preparedImage else { return }
        isProcessing = true
        detector.detect(image: preparedImage) { detected in
            detections = detected
            isProcessing = false
        }
    }
}

#Preview {
    ContentView()
}
