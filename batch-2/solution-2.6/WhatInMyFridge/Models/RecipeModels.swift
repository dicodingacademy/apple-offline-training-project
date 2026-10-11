//
//  RecipeModels.swift
//  WhatInMyFridge
//

import Foundation

// Bentuk resep yang dibaca tampilan. Hasil dari model bahasa diubah ke
// bentuk ini lebih dulu, jadi tampilan tidak perlu tahu cara resep dibuat.
struct RecipeData: Identifiable {
    let id = UUID()
    let recipeName: String
    let description: String
    let ingredients: [String]
    let steps: [String]
    let nutrition: NutritionInfo
}

struct NutritionInfo {
    let calories: String
    let protein: String
    let carbohydrates: String
    let fat: String
    let fiber: String
}
