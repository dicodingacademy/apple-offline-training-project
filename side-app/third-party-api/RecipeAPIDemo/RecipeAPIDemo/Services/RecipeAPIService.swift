import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case encodingFailed
    case noData
    case decodingFailed(String)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL tidak valid"
        case .encodingFailed: return "Gagal encode request"
        case .noData: return "Tidak ada data dari server"
        case .decodingFailed(let message): return "Gagal parse response: \(message)"
        case .apiError(let message): return "Error dari API: \(message)"
        }
    }
}

final class RecipeAPIService {
    func generateRecipe(ingredients: [String]) async throws -> RecipeData {
        guard let url = URL(string: Constants.aiEndpoint) else {
            throw APIError.invalidURL
        }

        let body = ChatRequest(
            model: Constants.aiModel,
            messages: [.init(role: "user", content: buildPrompt(ingredients: ingredients))]
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Tanpa header ini server menolak dengan status 415 Unsupported Media Type.
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.encodingFailed
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.apiError("Status \(http.statusCode): \(message)")
        }

        // Decode dua lapis: amplop chat completions dulu, lalu teks JSON di dalamnya.
        let chat = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = chat.firstContent, let json = content.data(using: .utf8) else {
            throw APIError.noData
        }

        do {
            return try JSONDecoder().decode(RecipeData.self, from: json)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    // Bentuk JSON diminta lewat contoh di dalam prompt. Model bisa saja tidak
    // menurut, dan itulah yang ditangkap `decodingFailed`.
    private func buildPrompt(ingredients: [String]) -> String {
        """
        You are a professional chef. Always reply with valid JSON in English.
        I have these ingredients: \(ingredients.joined(separator: ", ")).

        Create one recipe that can be made from them.
        Return JSON with EXACTLY this structure:
        {
          "recipe_name": "recipe name",
          "description": "short description, one or two sentences",
          "ingredients": ["ingredient 1 with amount", "ingredient 2 with amount"],
          "steps": ["step 1", "step 2", "step 3"],
          "nutrition": {
            "calories": "350 kcal",
            "protein": "25g",
            "carbohydrates": "40g",
            "fat": "12g",
            "fiber": "5g"
          }
        }
        """
    }
}
