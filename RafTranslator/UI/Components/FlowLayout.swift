import SwiftUI

/// Wraps its children onto multiple rows, matching Android Compose's `FlowRow` badge layout.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrangement(for: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangement(for: proposal, subviews: subviews)
        for (index, origin) in result.origins.enumerated() {
            let point = CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y)
            subviews[index].place(at: point, proposal: .unspecified)
        }
    }

    private func arrangement(for proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, origins: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        let totalWidth = maxWidth.isFinite ? maxWidth : x
        return (CGSize(width: totalWidth, height: y + rowHeight), origins)
    }
}
