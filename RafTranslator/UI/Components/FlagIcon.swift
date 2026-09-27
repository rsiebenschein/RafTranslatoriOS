import SwiftUI

/// Renders a dialect's flag/crest from the bundled `Assets.xcassets` SVG imagesets that
/// `scripts/fetch_flag_assets.py` generates from `flatAssetUri`, falling back to the emoji
/// when no image exists for that asset code (e.g. an unfetched placeholder or a custom
/// dialect with a pasted icon URL, which this view does not download).
struct FlagIcon: View {
    let flatAssetUri: String?
    let flagEmoji: String
    var size: CGFloat = 28
    var clipToCircle: Bool = true

    var body: some View {
        Group {
            if let name = resolvedImageName {
                Image(name).resizable().aspectRatio(contentMode: .fill)
            } else {
                Text(flagEmoji).font(.system(size: size * 0.75))
            }
        }
        .frame(width: size, height: size)
        .clipShape(clipToCircle ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: size * 0.15)))
    }

    private var resolvedImageName: String? {
        guard let flat = flatAssetUri, flat.hasPrefix("flag-") else { return nil }
        let roundName = "round-" + flat.dropFirst("flag-".count)
        if UIImage(named: roundName) != nil { return roundName }
        return UIImage(named: flat) != nil ? flat : nil
    }
}

#Preview {
    HStack(spacing: 12) {
        FlagIcon(flatAssetUri: "flag-de", flagEmoji: "🇩🇪", size: 40)
        FlagIcon(flatAssetUri: "flag-ch-zh", flagEmoji: "🇨🇭", size: 40)
        FlagIcon(flatAssetUri: nil, flagEmoji: "🏳️", size: 40)
    }
    .padding()
}
