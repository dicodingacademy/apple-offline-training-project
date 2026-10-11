import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var summarizer = DocumentSummarizer()
    @State private var selectedItem: PhotosPickerItem?
    @State private var previewImage: UIImage?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Pilih Foto Dokumen", systemImage: "doc.viewfinder")
                    }
                    .disabled(summarizer.isWorking)

                    if let previewImage {
                        Image(uiImage: previewImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .frame(maxWidth: .infinity)
                    }
                } footer: {
                    Text("Foto halaman buku, slide, atau artikel berbahasa Inggris.")
                }

                if let status = summarizer.status {
                    Section {
                        HStack {
                            ProgressView()
                            Text(status)
                        }
                    }
                }

                if let errorMessage = summarizer.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }

                if !summarizer.recognizedText.isEmpty {
                    Section {
                        DisclosureGroup("Teks hasil OCR") {
                            Text(summarizer.recognizedText)
                                .font(.caption)
                                .textSelection(.enabled)
                        }
                    }
                }

                if let summary = summarizer.summary {
                    SummarySections(summary: summary)
                }
            }
            .navigationTitle("Ringkas Dokumen")
            .onChange(of: selectedItem) { _, item in
                guard let item else { return }
                Task { await load(item) }
            }
        }
    }

    private func load(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            summarizer.errorMessage = "Foto gagal dimuat."
            return
        }
        previewImage = UIImage(data: data)
        await summarizer.summarize(imageData: data)
    }
}

struct SummarySections: View {
    let summary: DocumentSummary

    var body: some View {
        Section("Judul") {
            Text(summary.title)
                .font(.headline)
        }

        Section("Poin Utama") {
            ForEach(summary.keyPoints, id: \.self) { point in
                Label(point, systemImage: "checkmark.circle")
            }
        }

        if !summary.keywords.isEmpty {
            Section("Kata Kunci") {
                Text(summary.keywords.joined(separator: " · "))
                    .foregroundStyle(.secondary)
            }
        }

        Section("Pertanyaan Latihan") {
            ForEach(Array(summary.questions.enumerated()), id: \.offset) { index, question in
                Text("\(index + 1). \(question)")
            }
        }
    }
}

#Preview {
    ContentView()
}
