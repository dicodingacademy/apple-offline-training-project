import CoreML
import NaturalLanguage

/// Membungkus model CoreML `BERTIndonesiaTagger.mlmodel` (asli: "BERT-Indonesia",
/// tipe `wordTagger` untuk Named Entity Recognition Bahasa Indonesia) dengan
/// framework **NaturalLanguage** — bukan Vision, karena input/output-nya teks,
/// bukan gambar. Ini cara resmi Apple mengintegrasikan model Word Tagger
/// custom hasil CreateML: bungkus `MLModel` jadi `NLModel`, lalu pasang ke
/// `NLTagger` lewat `setModels(_:forTagScheme:)`.
final class NERTaggerService {
    private let scheme = NLTagScheme("BERTIndonesiaEntity")
    private var nlModel: NLModel?

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "BERTIndonesiaTagger", withExtension: "mlmodelc") else {
                print("NERTaggerService: model tidak ditemukan di bundle")
                return
            }
            let mlModel = try MLModel(contentsOf: url)
            nlModel = try NLModel(mlModel: mlModel)
        } catch {
            print("NERTaggerService: gagal load model — \(error)")
        }
    }

    func tag(text: String) -> [TaggedToken] {
        guard let nlModel, !text.isEmpty else { return [] }

        let tagger = NLTagger(tagSchemes: [scheme])
        tagger.string = text
        tagger.setModels([nlModel], forTagScheme: scheme)

        var results: [TaggedToken] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: scheme, options: [.omitWhitespace, .omitPunctuation]) { tag, range in
            let token = String(text[range])
            results.append(TaggedToken(token: token, tag: tag?.rawValue ?? "O"))
            return true
        }
        return results
    }
}
