import SwiftUI

/// "Target Language / Dialect" card: opens the searchable picker sheet on tap.
struct TargetLanguageSection: View {
    let viewModel: SettingsViewModel
    let allLanguages: [LanguageDialect]

    @State private var isPickerOpen = false

    var body: some View {
        Section {
            Button {
                isPickerOpen = true
            } label: {
                HStack {
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
