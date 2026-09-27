import SwiftUI
import SwiftData

/// Routes to the Swiss-German-dialect-themed screen or the generic-language screen depending
/// on the active target dialect's group, mirroring Android's `MainActivity` screen selection.
struct MainTranslateView: View {
    @Query private var allLanguages: [LanguageDialect]
    @State private var viewModel = TranslateViewModel()

    private var activeDialect: LanguageDialect? {
        allLanguages.first { $0.name == viewModel.settings.targetLanguage }
    }

    var body: some View {
        Group {
            if activeDialect?.groupKey == "swiss-german" {
                SwissDialectMainScreen(viewModel: viewModel, activeDialect: activeDialect)
            } else {
                GenericMainScreen(viewModel: viewModel, activeDialect: activeDialect)
            }
        }
        .onAppear { viewModel.reloadSettings() }
    }
}

#Preview {
    NavigationStack { MainTranslateView() }
}
