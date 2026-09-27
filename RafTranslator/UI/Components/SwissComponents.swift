import SwiftUI

/// Authentic Swiss cross badge (white cross on Swiss-red background), matching the Android
/// app's `SwissCrossBadge`.
struct SwissCrossBadge: View {
    var size: CGFloat = 24

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(AppTheme.swissRed)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.22)
                        .stroke(.white.opacity(0.35), lineWidth: 0.5)
                )
            Rectangle().fill(.white).frame(width: size * 0.62, height: size * 0.22)
            Rectangle().fill(.white).frame(width: size * 0.22, height: size * 0.62)
        }
        .frame(width: size, height: size)
    }
}

/// Small rounded pill used for the playful feature badges on both hero banners.
struct FeatureBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
    }
}

/// Hero banner for the Swiss-German-dialect screen, matching Android's `SwissHeroBanner`:
/// a bundled Matterhorn photo with a gradient overlay and title, badges below.
struct SwissHeroBanner: View {
    private let badges = ["🫕 Fondue-tauglich", "🧀 100% Chääs-Garantie", "🏔️ Matterhorn-geprüft", "🇨🇭 Zero Bünzli-Bürokratie"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            heroImage
            VStack(alignment: .leading, spacing: 8) {
                Text("Schnäll wie d'SBB, präzis wie es Schwiizer Uhrwärch und 100% Bünzli-approved.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                FlowLayout(spacing: 6) {
                    ForEach(badges, id: \.self) { FeatureBadge(text: $0) }
                }
            }
            .padding(14)
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var heroImage: some View {
        Image("SwissAlpsHero")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 130)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [.black.opacity(0.15), .black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 10) {
                    SwissCrossBadge(size: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Grüezi mitenand! 🇨🇭").font(.title3.bold()).foregroundStyle(.white)
                        Text("Eidgenössischer Dialäkt-Übersetzer")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.92))
                    }
                }
                .padding(14)
            }
    }
}

#Preview {
    SwissHeroBanner().padding()
}
