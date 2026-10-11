//
//  Recipe.swift
//  AppIntentFoundationModelDemo
//

import Foundation
import FoundationModels

// Bentuk resep yang diminta ke model. Karena @Generable, jawaban model
// langsung berupa struct ini, tanpa JSON yang perlu diurai sendiri.
@Generable
struct Recipe {
    @Guide(description: "Short, appetizing name of the dish")
    let title: String

    @Guide(description: "Total cooking time in minutes", .range(5...120))
    let minutes: Int

    @Guide(description: "Ingredients with rough amounts, mostly taken from the pantry list", .count(3...8))
    let ingredients: [String]

    @Guide(description: "Short cooking steps, one action per step", .count(3...6))
    let steps: [String]
}
