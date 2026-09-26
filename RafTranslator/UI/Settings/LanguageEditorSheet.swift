import SwiftUI
import SwiftData

/// Edit form for an existing `LanguageDialect`, presented over the language picker sheet.
struct LanguageEditorSheet: View {
    let viewModel: SettingsViewModel

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                LanguageDraftFields(draft: Binding(
                    get: { viewModel.editingDraft },
                    set: { viewModel.editingDraft = $0 }
                ))
            }
            .navigationTitle("Edit Language")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelEditing()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Changes") {
                        viewModel.saveEditedLanguage(context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.editingDraft.isValid)
                }
            }
        }
    }
}

/// Shared name/flag/country/keywords fields for both the inline add-language card and the edit
/// sheet, avoiding two near-identical forms.
struct LanguageDraftFields: View {
    @Binding var draft: LanguageDraft

    var body: some View {
        Section("Language / Dialect") {
            TextField("Language / Dialect Name", text: $draft.name)
            TextField("Flag emoji (e.g. 🇨🇭)", text: $draft.flagEmoji)
            TextField("Country code (e.g. CH)", text: $draft.countryCode)
                .textInputAutocapitalization(.characters)
        }
        Section("Search keywords") {
            TextField("Comma-separated, optional", text: $draft.searchKeywords)
        }
    }
}
