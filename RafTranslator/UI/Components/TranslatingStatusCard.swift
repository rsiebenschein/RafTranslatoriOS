import SwiftUI

/// Shown while a translation request is in flight.
struct TranslatingStatusCard: View {
    let model: String

    var body: some View {
        HStack(spacing: 14) {
            ProgressView()
            VStack(alignment: .leading, spacing: 2) {
                Text("Translating…")
                    .font(.subheadline.bold())
                Text("Getting translation from Gemini \(model)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    TranslatingStatusCard(model: "gemini-2.5-flash-lite").padding()
}
