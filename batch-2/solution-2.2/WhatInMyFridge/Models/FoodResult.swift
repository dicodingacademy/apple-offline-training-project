//
//  FoodResult.swift
//  WhatInMyFridge
//

import Foundation

// Dibuat sebagai struct, bukan class, karena hasil deteksi bersifat immutable.
// Identifiable dipakai supaya ForEach di SwiftUI bisa mengiterasi tanpa id: eksplisit.
struct FoodResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double

    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
}
