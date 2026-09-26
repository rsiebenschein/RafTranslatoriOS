import Foundation
import SwiftData

/// Add/edit/delete/select handling for the language/dialect catalog, backed by SwiftData.
extension SettingsViewModel {
    func selectLanguage(_ dialect: LanguageDialect) {
        draft.targetLanguage = dialect.name
    }

    func addNewLanguage(context: ModelContext) {
        guard newLanguageDraft.isValid, !isSavingLanguage else { return }
        isSavingLanguage = true
        defer { isSavingLanguage = false }

        let dialect = LanguageDialect(
            name: newLanguageDraft.name.trimmingCharacters(in: .whitespaces),
            countryCode: newLanguageDraft.countryCode.trimmingCharacters(in: .whitespaces).uppercased(),
            flagEmoji: newLanguageDraft.flagEmoji,
            isCustom: true,
            languageNameEnglish: newLanguageDraft.name.trimmingCharacters(in: .whitespaces),
            languageNameNative: newLanguageDraft.name.trimmingCharacters(in: .whitespaces),
            isUserModified: true,
            searchKeywords: newLanguageDraft.searchKeywords.trimmingCharacters(in: .whitespaces)
        )
        context.insert(dialect)
        do {
            try context.save()
            draft.targetLanguage = dialect.name
            addLanguageMessage = "Added \(dialect.name)."
            newLanguageDraft = LanguageDraft()
        } catch {
            addLanguageMessage = "Couldn't add language: \(error.localizedDescription)"
        }
    }

    func startEditing(_ dialect: LanguageDialect) {
        editingLanguage = dialect
        editingDraft = .from(dialect)
    }

    func cancelEditing() {
        editingLanguage = nil
    }

    func saveEditedLanguage(context: ModelContext) {
        guard let dialect = editingLanguage, editingDraft.isValid else { return }
        let renamedTo = editingDraft.name.trimmingCharacters(in: .whitespaces)
        let wasSelected = dialect.name == draft.targetLanguage
        editingDraft.apply(to: dialect)
        if wasSelected { draft.targetLanguage = renamedTo }
        try? context.save()
        editingLanguage = nil
    }

    /// Mirrors the Android picker's rule: the default Zürcher dialect can't be deleted while it's
    /// the only entry left, so the picker never ends up empty.
    func canDelete(_ dialect: LanguageDialect, among allLanguages: [LanguageDialect]) -> Bool {
        let isDefaultZueri = dialect.name.contains("Zürcher")
        return dialect.isCustom || (!isDefaultZueri && allLanguages.count > 1)
    }

    func delete(_ dialect: LanguageDialect, context: ModelContext) {
        let wasSelected = dialect.name == draft.targetLanguage
        context.delete(dialect)
        try? context.save()
        if wasSelected {
            draft.targetLanguage = (try? context.fetch(FetchDescriptor<LanguageDialect>()))?.first?.name
                ?? AppSettings.defaultLanguage
        }
    }
}
