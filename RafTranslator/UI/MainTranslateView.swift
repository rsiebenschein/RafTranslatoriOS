import SwiftUI
import SwiftData

/// The core translate screen: text entry + dictation, translate button, and the result card.
/// Mirrors the Android app's `SwissDialectMainScreen`/`GenericMainScreen`, unified into one view
/// since their divergence was purely cosmetic flavor text, not structure.
struct MainTranslateView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TranslateViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.settings.apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
                    ApiKeyWarningBanner()
                }
                TranslateInputCard(viewModel: viewModel)
                TranslateButton(viewModel: viewModel, modelContext: modelContext)
                if viewModel.isTranslating {
                    TranslatingStatusCard(model: viewModel.settings.selectedModel)
                }
                if let error = viewModel.translationError, !viewModel.isTranslating {
                    TranslationErrorCard(message: error)
                }
                if let result = viewModel.translationResult, !viewModel.isTranslating {
                    TranslationResultCard(result: result, viewModel: viewModel)
                }
            }
            .padding(16)
        }
        .navigationTitle("Raf Translator")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .onAppear { viewModel.reloadSettings() }
    }
}

private struct TranslateButton: View {
    @Bindable var viewModel: TranslateViewModel
    let modelContext: ModelContext

    var body: some View {
        Button {
            Task { await viewModel.translate(modelContext: modelContext) }
        } label: {
            Label("Translate into \(viewModel.settings.targetLanguage)", systemImage: "character.bubble")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isTranslating)
    }
}

#Preview {
    NavigationStack {
        MainTranslateView()
    }
}
