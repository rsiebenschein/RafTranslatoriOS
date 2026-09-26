import SwiftUI

/// Tappable warning shown on the main screen until a Gemini API key is configured.
struct ApiKeyWarningBanner: View {
    var body: some View {
        NavigationLink {
            SettingsView()
        } label: {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Gemini API Key Required")
                        .font(.subheadline.bold())
                    Text("Tap here to open Settings and configure your Google Gemini API Key.")
                        .font(.caption)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.primary)
        }
        .tint(.primary)
    }
}

#Preview {
    NavigationStack { ApiKeyWarningBanner().padding() }
}
