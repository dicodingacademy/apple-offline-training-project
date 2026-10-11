import Foundation
import CoreGraphics

struct DetectionResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    /// Normalized, koordinat Vision (origin di kiri-bawah).
    let boundingBox: CGRect
}
