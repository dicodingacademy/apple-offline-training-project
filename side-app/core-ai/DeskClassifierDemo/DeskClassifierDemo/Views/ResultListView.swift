import SwiftUI

struct ResultListView: View {
    let results: [ClassificationResult]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hasil Klasifikasi (Top 3)")
                .font(.headline)
                .padding(.bottom, 8)

            ForEach(results) { result in
                HStack {
                    VStack(alignment: .leading) {
                        Text(result.displayName)
                        Text(result.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(Int(result.confidence * 100))%")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
