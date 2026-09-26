import SwiftUI

/// The text-entry card: dictate button, multiline text field, and a clear button.
struct TranslateInputCard: View {
    @Bindable var viewModel: TranslateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Translate into \(viewModel.settings.targetLanguage):")
                    .font(.subheadline.bold())
                Spacer()
                DictateButton(viewModel: viewModel)
            }
            TextEditor(text: $viewModel.inputText)
                .frame(minHeight: 120)
                .overlay(alignment: .topLeading) {
                    if viewModel.inputText.isEmpty {
                        Text("Type or dictate in English or German here…")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
                .padding(6)
                .background(.background, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.tertiary))
            if !viewModel.inputText.isEmpty {
                Button("Clear", role: .destructive) { viewModel.clearInput() }
                    .font(.caption)
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct DictateButton: View {
    @Bindable var viewModel: TranslateViewModel

    var body: some View {
        Button {
            Task { await viewModel.toggleDictation() }
        } label: {
            Image(systemName: viewModel.dictation.isRecording ? "mic.fill" : "mic")
                .padding(8)
                .background(viewModel.dictation.isRecording ? .red : .accentColor, in: Circle())
                .foregroundStyle(.white)
        }
    }
}
