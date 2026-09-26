import SwiftUI
import SwiftData

/// "Add Custom Language / Dialect" card: name, flag emoji, country code, and search keywords.
struct AddLanguageSection: View {
    let viewModel: SettingsViewModel

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Section {
            LanguageDraftFields(draft: Binding(
                get: { viewModel.newLanguageDraft },
                set: { viewModel.newLanguageDraft = $0 }
            ))

            if let message = viewModel.addLanguageMessage {
                Text(message).font(.caption).foregroundStyle(.secondary)
            }

            Button {
                viewModel.addNewLanguage(context: modelContext)
            } label: {
                if viewModel.isSavingLanguage {
                    ProgressView()
                } else {
                    Label("Add & Select Language", systemImage: "plus")
                }
            }
            .disabled(!viewModel.newLanguageDraft.isValid || viewModel.isSavingLanguage)
        } header: {
            Text("Add Custom Language / Dialect")
        } footer: {
            Text("Saved permanently to the local database.")
        }
    }
}
