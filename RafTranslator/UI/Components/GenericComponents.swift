import SwiftUI

/// Hero banner for every non-Swiss-German target language: a gradient backdrop, the target
/// language's own flag, and its localized greeting — mirrors Android's `GenericHeroBanner`.
struct GenericHeroBanner: View {
    let flatAssetUri: String?
    let flagEmoji: String
    let greeting: String

    private let badges = ["⚡ Fast", "🎯 Precise", "🌍 185+ Languages"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            FlowLayout(spacing: 6) {
                ForEach(badges, id: \.self) { FeatureBadge(text: $0) }
            }
            .padding(14)
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var headerRow: some View {
        HStack(spacing: 14) {
            FlagIcon(flatAssetUri: flatAssetUri, flagEmoji: flagEmoji, size: 58)
                .padding(5)
                .background(.white.opacity(0.18), in: Circle())
            Text(greeting)
                .font(.title2.bold())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
        .background(LinearGradient(colors: [.accentColor, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

#Preview {
    GenericHeroBanner(flatAssetUri: "flag-de", flagEmoji: "🇩🇪", greeting: "Hallo zusammen!").padding()
}
