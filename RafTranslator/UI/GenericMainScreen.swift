import SwiftUI
import SwiftData

/// The main screen for every non-Swiss-German target language: a themed hero banner with the
/// target language's own flag and localized greeting. Mirrors Android's `GenericMainScreen`.
struct GenericMainScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: TranslateViewModel
    let activeDialect: LanguageDialect?

    private var uiStrings: LanguageUiStrings {
        LanguageUiStringsCatalog.strings(forSeedKey: activeDialect?.seedKey)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GenericHeroBanner(
                    flatAssetUri: activeDialect?.flatAssetUri,
                    flagEmoji: activeDialect?.flagEmoji ?? "🌍",
                    greeting: uiStrings.greeting
                )
                if viewModel.settings.apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
                    ApiKeyWarningBanner()
                }
                TranslateInputCard(viewModel: viewModel, activeDialect: activeDialect, clipFlagToCircle: true)
                MainTranslateButton(
                    viewModel: viewModel,
                    modelContext: modelContext,
                    label: "\(uiStrings.buttonLabel) (\(viewModel.settings.targetLanguage))"
                )
                resultSection
            }
            .padding(16)
        }
        .navigationTitle("Raf's Babel Translator")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink { SettingsView() } label: { Image(systemName: "gearshape") }
            }
        }
    }

    @ViewBuilder
    private var resultSection: some View {
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
}

#Preview {
    NavigationStack { GenericMainScreen(viewModel: TranslateViewModel(), activeDialect: nil) }
}
