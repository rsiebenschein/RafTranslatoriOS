import SwiftUI

/// "Target Language / Dialect" card: opens the searchable picker sheet on tap.
struct TargetLanguageSection: View {
    let viewModel: SettingsViewModel
    let allLanguages: [LanguageDialect]

    @State private var isPickerOpen = false

    private var selectedDialect: LanguageDialect? {
        allLanguages.first { $0.name == viewModel.draft.targetLanguage }
    }

    var body: some View {
        Section {
            Button {
                isPickerOpen = true
            } label: {
                HStack {
                    FlagIcon(flatAssetUri: selectedDialect?.flatAssetUri, flagEmoji: selectedDialect?.flagEmoji ?? "🏳️", size: 26)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Target Language / Dialect").font(.caption).foregroundStyle(.secondary)
                        Text(viewModel.draft.targetLanguage).foregroundStyle(.primary)
                    }
                    Spacer()
                    Text("Change").foregroundStyle(.tint)
                }
            }
        } header: {
            Text("Target Language / Dialect")
        } footer: {
            Text("Select your target language or dialect from the searchable list.")
        }
        .sheet(isPresented: $isPickerOpen) {
            LanguagePickerSheet(
                allLanguages: allLanguages,
                selectedName: viewModel.draft.targetLanguage,
                viewModel: viewModel,
                onSelect: viewModel.selectLanguage
            )
        }
        .sheet(item: Binding(
            get: { viewModel.editingLanguage },
            set: { viewModel.editingLanguage = $0 }
        )) { _ in
            LanguageEditorSheet(viewModel: viewModel)
        }
    }
}
