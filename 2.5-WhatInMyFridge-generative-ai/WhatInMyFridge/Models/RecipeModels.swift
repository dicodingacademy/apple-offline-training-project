import Foundation

// MARK: - Request

struct OpenAIRequest: Encodable {
    let model: String
    let messages: [Message]

    struct Message: Encodable {
        let role: String
        let content: String
    }
}

// MARK: - Response

struct OpenAIResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message

        struct Message: Decodable {
            let content: String
        }
    }

    var firstContent: String? { choices.first?.message.content }
}

// MARK: - Recipe Data

struct RecipeData: Decodable, Identifiable {
    let id = UUID()
    let recipeName: String
    let description: String
    let ingredients: [String]
    let steps: [String]
    let nutrition: NutritionInfo

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
