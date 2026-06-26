import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case encodingFailed
    case noData
    case decodingFailed(String)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:         return "URL tidak valid"
        case .encodingFailed:     return "Gagal encode request"
        case .noData:             return "Tidak ada data dari server"
        case .decodingFailed(let msg): return "Gagal parse response: \(msg)"
        case .apiError(let msg):  return "Error dari API: \(msg)"
        }
    }
}

final class RecipeAPIService {
    func generateRecipe(ingredients: [String]) async throws -> RecipeData {
        guard let url = URL(string: Constants.aiEndpoint) else {
            throw APIError.invalidURL
        }

        let prompt = buildPrompt(ingredients: ingredients)
        let requestBody = OpenAIRequest(
            model: Constants.aiModel,
            messages: [
                OpenAIRequest.Message(role: "user", content: prompt)
            ]
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw APIError.encodingFailed
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.apiError("Status \(httpResponse.statusCode): \(errorMessage)")
        }

        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let jsonString = openAIResponse.firstContent,
              let jsonData = jsonString.data(using: .utf8) else {
            throw APIError.noData
        }

        do {
            return try JSONDecoder().decode(RecipeData.self, from: jsonData)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    private func buildPrompt(ingredients: [String]) -> String {
        let ingredientList = ingredients.joined(separator: ", ")
        return """
        Kamu adalah chef profesional. Selalu kembalikan respons dalam format JSON yang valid berbahasa indonesia.
        Saya memiliki bahan-bahan berikut: \(ingredientList).

        Buatkan 1 resep masakan yang bisa dibuat dari bahan tersebut.
        Kembalikan dalam format JSON dengan struktur PERSIS seperti ini:
        {
          "recipe_name": "nama resep",
          "description": "deskripsi singkat 1-2 kalimat",
          "ingredients": ["bahan 1 dengan takaran", "bahan 2 dengan takaran"],
          "steps": ["langkah 1", "langkah 2", "langkah 3"],
          "nutrition": {
            "calories": "350 kkal",
            "protein": "25g",
            "carbohydrates": "40g",
            "fat": "12g",
            "fiber": "5g"
          }
        }
        """
    }
}
