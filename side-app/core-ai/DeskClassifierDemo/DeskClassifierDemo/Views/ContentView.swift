import SwiftUI

struct ContentView: View {
    @State private var classifier = DeskClassifierService()
    @State private var modelState: ModelState = .loading

    enum ModelState {
        case loading, ready, failed
    }

    var body: some View {
        TabView {
            Tab("Foto", systemImage: "photo") {
                PhotoClassifierView(classifier: classifier, modelState: modelState)
            }
            Tab("Kamera Live", systemImage: "camera.viewfinder") {
                LiveCameraView(classifier: classifier)
            }
        }
        .task {
            modelState = await classifier.prepare() ? .ready : .failed
        }
    }
}

#Preview {
    ContentView()
}
