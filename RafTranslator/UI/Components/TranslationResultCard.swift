import SwiftUI

/// The translated-text result: selectable output, token-usage line, copy, and share.
/// Cost display (not just token counts) is added in the usage/cost-tracking step.
struct TranslationResultCard: View {
    let result: TranslationResult
    @Bindable var viewModel: TranslateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(result.text)
                .textSelection(.enabled)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))

            TokenUsageLine(result: result)

            HStack {
                Spacer()
                CopyButton(viewModel: viewModel)
                ShareLink(item: result.text) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct CopyButton: View {
    @Bindable var viewModel: TranslateViewModel

    var body: some View {
        Button {
            viewModel.copyTranslationToClipboard()
        } label: {
            Label(viewModel.isCopied ? "Copied! ✓" : "Copy", systemImage: viewModel.isCopied ? "checkmark" : "doc.on.doc")
        }
        .buttonStyle(.borderedProminent)
        .tint(viewModel.isCopied ? .green : .accentColor)
    }
}

private struct TokenUsageLine: View {
    let result: TranslationResult

    var body: some View {
        Text("\(result.totalTokenCount) tokens (\(result.promptTokenCount) in / \(result.candidatesTokenCount) out)")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
