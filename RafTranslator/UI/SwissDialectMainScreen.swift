import SwiftUI
import SwiftData

/// The Swiss-German-canton-themed main screen, shown when the active target dialect belongs
/// to the "swiss-german" group. Mirrors Android's `SwissDialectMainScreen`.
struct SwissDialectMainScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: TranslateViewModel
    let activeDialect: LanguageDialect?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SwissHeroBanner()
                if viewModel.settings.apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
                    ApiKeyWarningBanner()
                }
                TranslateInputCard(viewModel: viewModel, activeDialect: activeDialect, clipFlagToCircle: false)
                MainTranslateButton(
                    viewModel: viewModel,
                    modelContext: modelContext,
                    label: "🇨🇭 Ab di Poscht! Ins \(viewModel.settings.targetLanguage) übersetze"
                )
                resultSection
            }
            .padding(16)
        }
        .navigationTitle("Eidgenössischer Übersetzer 🇨🇭")
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
    NavigationStack { SwissDialectMainScreen(viewModel: TranslateViewModel(), activeDialect: nil) }
}
