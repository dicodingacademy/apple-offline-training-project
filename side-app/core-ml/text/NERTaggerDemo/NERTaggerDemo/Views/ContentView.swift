import SwiftUI

struct ContentView: View {
    @State private var text = "Budi pergi ke Jakarta bersama Siti pada tanggal 17 Agustus untuk menghadiri acara di Monas."
    @State private var taggedTokens: [TaggedToken] = []

    private let tagger = NERTaggerService()

    var body: some View {
        NavigationStack {
            Form {
                Section("Teks (Bahasa Indonesia)") {
                    TextEditor(text: $text)
                        .frame(minHeight: 120)
                    Button("Analisis Entitas") { analyze() }
                }

                if !taggedTokens.isEmpty {
                    Section("Hasil Tagging") {
                        FlowTokens(tokens: taggedTokens)
                    }

                    let entities = taggedTokens.filter(\.isEntity)
                    if !entities.isEmpty {
                        Section("Entitas Terdeteksi") {
                            ForEach(entities) { token in
                                HStack {
                                    Text(token.token)
                                    Spacer()
                                    Text(token.tag)
                                        .font(.caption).bold()
                                        .padding(.horizontal, 8).padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("NER Tagger Demo")
        }
    }

    private func analyze() {
        taggedTokens = tagger.tag(text: text)
    }
}

private struct FlowTokens: View {
    let tokens: [TaggedToken]

    var body: some View {
        // Layout sederhana per-baris (bukan flow-wrap) supaya tidak perlu
        // custom Layout — cukup untuk demo dasar.
        VStack(alignment: .leading, spacing: 6) {
            ForEach(tokens) { token in
                HStack {
                    Text(token.token)
                    Spacer()
                    Text(token.tag)
                        .font(.caption2)
                        .foregroundStyle(token.isEntity ? .white : .secondary)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(token.isEntity ? Color.green : Color.clear)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
