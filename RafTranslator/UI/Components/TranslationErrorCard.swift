import SwiftUI

/// Shown when the last translation attempt failed.
struct TranslationErrorCard: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
            VStack(alignment: .leading, spacing: 2) {
                Text("Translation Issue")
                    .font(.subheadline.bold())
                Text(message)
                    .font(.caption)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    TranslationErrorCard(message: "Gemini API Error (429): Rate limited").padding()
}
