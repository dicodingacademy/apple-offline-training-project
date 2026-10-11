import SwiftUI

struct ContentView: View {
    @State private var assistant = ScheduleAssistant()
    @State private var question = ""

    private let suggestions = [
        "When am I free on Wednesday?",
        "What do I have on Thursday?",
        "Is Sunday free for a trip?",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if assistant.messages.isEmpty {
                            SuggestionList(suggestions: suggestions) { suggestion in
                                send(suggestion)
                            }
                        }

                        ForEach(assistant.messages) { message in
                            MessageBubble(message: message)
                        }

                        if assistant.isResponding {
                            ProgressView()
                        }

                        if let errorMessage = assistant.errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                }

                HStack {
                    TextField("Tanya jadwal (Bahasa Inggris)", text: $question)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { send(question) }
                    Button("Kirim", systemImage: "paperplane.fill") {
                        send(question)
                    }
                    .labelStyle(.iconOnly)
                    .disabled(question.trimmingCharacters(in: .whitespaces).isEmpty || assistant.isResponding)
                }
                .padding()
            }
            .navigationTitle("Asisten Jadwal")
            .toolbar {
                NavigationLink {
                    ScheduleListView()
                } label: {
                    Label("Jadwal", systemImage: "calendar")
                }
                Button("Ulang", systemImage: "arrow.counterclockwise") {
                    assistant.reset()
                }
                .disabled(assistant.isResponding)
            }
        }
    }

    private func send(_ text: String) {
        let text = text.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !assistant.isResponding else { return }
        question = ""
        Task { await assistant.ask(text) }
    }
}

struct SuggestionList: View {
    let suggestions: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coba tanyakan:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ForEach(suggestions, id: \.self) { suggestion in
                Button(suggestion) { onSelect(suggestion) }
                    .buttonStyle(.bordered)
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        switch message.role {
        case .user:
            HStack {
                Spacer(minLength: 40)
                Text(message.text)
                    .padding(10)
                    .background(.tint, in: .rect(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
        case .assistant:
            HStack {
                Text(message.text)
                    .padding(10)
                    .background(.gray.opacity(0.15), in: .rect(cornerRadius: 12))
                Spacer(minLength: 40)
            }
        case .toolCall:
            Label(message.text, systemImage: "wrench.and.screwdriver")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

// Data yang sama dengan yang dibaca FindEventsTool, untuk mencocokkan jawaban model.
struct ScheduleListView: View {
    var body: some View {
        List(SampleSchedule.days, id: \.self) { day in
            Section(day) {
                let events = SampleSchedule.events(on: day)
                if events.isEmpty {
                    Text("Kosong")
                        .foregroundStyle(.secondary)
                }
                ForEach(events) { event in
                    HStack {
                        Text("\(event.start)–\(event.end)")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Text(event.title)
                    }
                }
            }
        }
        .navigationTitle("Jadwal Minggu Ini")
    }
}

#Preview {
    ContentView()
}
