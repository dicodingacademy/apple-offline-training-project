import AVFoundation
import SoundAnalysis
import CoreML
import SwiftUI

/// Membungkus model CoreML `AnimalSoundClassifier.mlmodel` (asli: "Audio
/// Feature Print", klasifikasi 13 suara hewan) dengan framework
/// **SoundAnalysis** — bukan Vision, karena inputnya audio streaming dari
/// mikrofon, bukan gambar. Ini cara resmi Apple mengintegrasikan model Sound
/// Classifier custom hasil CreateML: bungkus `MLModel` jadi
/// `SNClassifySoundRequest`, lalu pasang ke `SNAudioStreamAnalyzer` yang
/// menganalisis buffer audio dari `AVAudioEngine` secara real-time.
@Observable
final class AnimalSoundClassifierManager: NSObject {
    var currentLabel: String?
    var confidence: Double = 0
    var isRunning = false
    var permissionDenied = false

    private let audioEngine = AVAudioEngine()
    private var streamAnalyzer: SNAudioStreamAnalyzer?
    private let analysisQueue = DispatchQueue(label: "sound.analysis.queue")
    private let resultsObserver = ResultsObserver()

    override init() {
        super.init()
        resultsObserver.onResult = { [weak self] label, confidence in
            DispatchQueue.main.async {
                self?.currentLabel = label
                self?.confidence = confidence
            }
        }
    }

    func startSession() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            startCapture()
        case .undetermined:
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                if granted {
                    self?.startCapture()
                } else {
                    DispatchQueue.main.async { self?.permissionDenied = true }
                }
            }
        default:
            permissionDenied = true
        }
    }

    private func startCapture() {
        do {
            guard let url = Bundle.main.url(forResource: "AnimalSoundClassifier", withExtension: "mlmodelc") else {
                print("AnimalSoundClassifierManager: model tidak ditemukan di bundle")
                return
            }
            let mlModel = try MLModel(contentsOf: url)
            let request = try SNClassifySoundRequest(mlModel: mlModel)

            // Sesi audio harus aktif untuk merekam sebelum format mikrofon dibaca.
            // Tanpa ini, format bisa kosong (sample rate 0), dan
            // SNAudioStreamAnalyzer langsung crash dengan InvalidFormatException.
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
            try session.setActive(true)

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            guard format.sampleRate > 0, format.channelCount > 0 else {
                print("AnimalSoundClassifierManager: format mikrofon tidak valid — \(format)")
                return
            }
            let analyzer = SNAudioStreamAnalyzer(format: format)
            try analyzer.add(request, withObserver: resultsObserver)
            streamAnalyzer = analyzer

            inputNode.installTap(onBus: 0, bufferSize: 8192, format: format) { [weak self] buffer, time in
                guard let self else { return }
                self.analysisQueue.async {
                    self.streamAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
                }
            }

            audioEngine.prepare()
            try audioEngine.start()
            DispatchQueue.main.async { self.isRunning = true }
        } catch {
            print("AnimalSoundClassifierManager: gagal start — \(error)")
        }
    }

    func stopSession() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        streamAnalyzer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isRunning = false
    }
}

/// Jembatan delegate `SNResultsObserving` (Objective-C style callback) ke closure Swift.
private final class ResultsObserver: NSObject, SNResultsObserving {
    var onResult: ((String, Double) -> Void)?

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let classification = result.classifications.first else { return }
        onResult?(classification.identifier, classification.confidence)
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("ResultsObserver: klasifikasi gagal — \(error)")
    }
}
