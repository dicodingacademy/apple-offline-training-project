import Foundation

// MARK: - Request

// Badan permintaan format chat completions.
struct ChatRequest: Encodable {
    let model: String
    let messages: [Message]

    struct Message: Encodable {
        let role: String
        let content: String
    }
}

// MARK: - Response

// Lapis luar jawaban. Resepnya ada di dalam `content` sebagai teks JSON.
struct ChatResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message

        struct Message: Decodable {
            let content: String
        }
    }

    // `first`, bukan `[0]`, supaya array kosong tidak membuat app crash.
    var firstContent: String? { choices.first?.message.content }
}

// MARK: - Recipe

// Lapis dalam jawaban, hasil decode dari isi `content`.
struct RecipeData: Decodable {
    let recipeName: String
    let description: String
    let ingredients: [String]
    let steps: [String]
    let nutrition: NutritionInfo

    // Server memakai `recipe_name`, Swift memakai `recipeName`.
    enum CodingKeys: String, CodingKey {
        case recipeName = "recipe_name"
        case description, ingredients, steps, nutrition
    }
}

struct NutritionInfo: Decodable {
    let calories: String
    let protein: String
    let carbohydrates: String
    let fat: String
    let fiber: String
}
