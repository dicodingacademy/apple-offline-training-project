import SwiftUI

struct ContentView: View {
    @State private var assistant = WritingAssistant()
    @State private var input = "hey sorry i cant come to the meeting tomorrow, something came up. can we move it to friday? thx"
    @State private var style: WritingStyle = .formal

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $input)
                        .frame(minHeight: 120)
                } header: {
                    Text("Teks asli")
                } footer: {
                    Text("Gunakan Bahasa Inggris. Model on-device belum mendukung Bahasa Indonesia.")
                }

                Section("Gaya") {
                    Picker("Gaya", selection: $style) {
                        ForEach(WritingStyle.allCases) { style in
                            Text(style.label).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button {
                        Task { await assistant.rewrite(input, style: style) }
                    } label: {
                        HStack {
                            Text("Tulis Ulang")
                            Spacer()
                            if assistant.isGenerating {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || assistant.isGenerating)
                }

                if let errorMessage = assistant.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }

                if !assistant.output.isEmpty {
                    Section("Hasil") {
                        Text(assistant.output)
                            .textSelection(.enabled)
                        Button("Salin", systemImage: "doc.on.doc") {
                            UIPasteboard.general.string = assistant.output
                        }
                        .disabled(assistant.isGenerating)
                    }
                }
            }
            .navigationTitle("Asisten Tulis")
        }
    }
}

#Preview {
    ContentView()
}
