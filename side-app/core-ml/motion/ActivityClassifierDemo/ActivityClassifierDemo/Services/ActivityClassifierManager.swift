import CoreMotion
import CoreML
import SwiftUI

/// Membungkus model CoreML `MyActivityClassifier.mlmodel` — HAR (Human
/// Activity Recognition) classifier STATEFUL yang aslinya dilatih dari 2
/// accelerometer terpisah yang dipakai di badan (punggung "back" & paha
/// "thigh"), memprediksi lying/sitting/standing/walking.
///
/// SIMPLIFIKASI: iPhone cuma punya 1 accelerometer, jadi demo ini memakai
/// stream accelerometer iPhone (`CMMotionManager`) yang sama untuk mengisi
/// slot "back" maupun "thigh". Hasil klasifikasi jadi kurang akurat
/// dibanding sensor asli, tapi pipeline integrasinya (termasuk cara
/// membawa state RNN antar window lewat stateIn/stateOut) tetap representatif.
///
/// Alur: accelerometer 20Hz → kumpulkan 100 sampel per window → jadikan
/// MLMultiArray [100] per sumbu → prediksi sambil membawa `stateIn` dari
/// `stateOut` window sebelumnya (wajib untuk model stateful/RNN).
@Observable
final class ActivityClassifierManager {
    private let sampleWindow = 100

    var currentLabel: String?
    var confidence: Double = 0
    var sampleProgress: Int = 0
    var isRunning = false
    var accelerometerUnavailable = false

    private let motionManager = CMMotionManager()
    private let motionQueue = OperationQueue()
    private var model: MLModel?
    private var stateArray: MLMultiArray?

    private var xBuffer: [Double] = []
    private var yBuffer: [Double] = []
    private var zBuffer: [Double] = []

    init() {
        setupModel()
        resetState()
    }

    private func setupModel() {
        do {
            guard let url = Bundle.main.url(forResource: "MyActivityClassifier", withExtension: "mlmodelc") else {
                print("ActivityClassifierManager: model tidak ditemukan di bundle")
                return
            }
            model = try MLModel(contentsOf: url)
        } catch {
            print("ActivityClassifierManager: gagal load model — \(error)")
        }
    }

    private func resetState() {
        guard let array = try? MLMultiArray(shape: [400], dataType: .double) else { return }
        for i in 0..<array.count { array[i] = 0 }
        stateArray = array
    }

    func startSession() {
        guard motionManager.isAccelerometerAvailable else {
            accelerometerUnavailable = true
            return
        }
        xBuffer.removeAll(); yBuffer.removeAll(); zBuffer.removeAll()
        motionManager.accelerometerUpdateInterval = 1.0 / 20.0
        motionManager.startAccelerometerUpdates(to: motionQueue) { [weak self] data, _ in
            guard let self, let data else { return }
            self.handle(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
        }
        isRunning = true
    }

    func stopSession() {
        motionManager.stopAccelerometerUpdates()
        isRunning = false
    }

    private func handle(x: Double, y: Double, z: Double) {
        xBuffer.append(x)
        yBuffer.append(y)
        zBuffer.append(z)

        let progress = xBuffer.count
        DispatchQueue.main.async { self.sampleProgress = progress }

        guard xBuffer.count == sampleWindow else { return }
        classifyWindow()
        xBuffer.removeAll(); yBuffer.removeAll(); zBuffer.removeAll()
    }

    private func classifyWindow() {
        guard let model, let stateArray else { return }
        do {
            let backX = try makeArray(xBuffer)
            let backY = try makeArray(yBuffer)
            let backZ = try makeArray(zBuffer)

            let provider = try MLDictionaryFeatureProvider(dictionary: [
                "back_x": backX, "back_y": backY, "back_z": backZ,
                "thigh_x": backX, "thigh_y": backY, "thigh_z": backZ,
                "stateIn": stateArray
            ])
            let output = try model.prediction(from: provider)

            guard let label = output.featureValue(for: "label")?.stringValue else { return }
            let probability = output.featureValue(for: "labelProbability")?.dictionaryValue[label]?.doubleValue ?? 0

            if let newState = output.featureValue(for: "stateOut")?.multiArrayValue {
                self.stateArray = newState
            }

            DispatchQueue.main.async {
                self.currentLabel = label
                self.confidence = probability
            }
        } catch {
            print("ActivityClassifierManager: prediction error — \(error)")
        }
    }

    private func makeArray(_ values: [Double]) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [NSNumber(value: values.count)], dataType: .double)
        for (index, value) in values.enumerated() {
            array[index] = NSNumber(value: value)
        }
        return array
    }
}
