//
//  ScheduleAssistant.swift
//  ScheduleToolDemo
//

import Foundation
import FoundationModels
import Observation

struct ChatMessage: Identifiable {
    enum Role {
        case user
        case assistant
        case toolCall
    }

    let id = UUID()
    let role: Role
    let text: String
}

@Observable
final class ScheduleAssistant {
    var messages: [ChatMessage] = []
    var isResponding = false
    var errorMessage: String?

    // Satu sesi dipakai sepanjang percakapan supaya model ingat konteks,
    // misalnya pertanyaan lanjutan "what about Friday?".
    private var session = ScheduleAssistant.makeSession()

    private static func makeSession() -> LanguageModelSession {
        LanguageModelSession(
            tools: [FindEventsTool()],
            instructions: """
                You are a helpful schedule assistant for a university student.
                Always call findEvents to check the schedule before answering. Never guess.
                Answer briefly in English.
                """
        )
    }

    func ask(_ question: String) async {
        errorMessage = nil
        messages.append(ChatMessage(role: .user, text: question))
        isResponding = true
        defer { isResponding = false }

        // Posisi transcript sebelum bertanya, supaya panggilan tool yang
        // baru terjadi bisa dipisahkan dari giliran sebelumnya.
        let startIndex = session.transcript.endIndex

        do {
            try OnDeviceModel.checkAvailability()
            let response = try await session.respond(to: question)
            messages.append(contentsOf: toolCalls(since: startIndex))
            messages.append(ChatMessage(role: .assistant, text: response.content))
        } catch {
            errorMessage = OnDeviceError(error).localizedDescription
        }
    }

    func reset() {
        session = ScheduleAssistant.makeSession()
        messages = []
        errorMessage = nil
    }

    // Transcript mencatat semua yang terjadi di sesi, termasuk tool yang
    // dipanggil model beserta argumennya. Ditampilkan di UI supaya proses
    // "model memanggil fungsi app" terlihat, bukan cuma jawaban akhirnya.
    private func toolCalls(since startIndex: Int) -> [ChatMessage] {
        session.transcript[startIndex...].flatMap { entry -> [ChatMessage] in
            guard case .toolCalls(let calls) = entry else { return [] }
            return calls.map { call in
                ChatMessage(role: .toolCall, text: "\(call.toolName)(\(call.arguments.jsonString))")
            }
        }
    }
}
