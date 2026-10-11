import Foundation

// Alamat layanan dan nama model dikumpulkan di satu tempat.
// Layanan Dicoding ini terbuka tanpa API key, jadi tidak ada kunci di sini.
// Untuk penyedia yang memakai kunci, jangan tulis kuncinya di dalam app.
enum Constants {
    static let aiEndpoint = "https://oss.dicoding-ai.dev/v1/chat/completions"
    static let aiModel = "openai/gpt-oss-20b"
}
