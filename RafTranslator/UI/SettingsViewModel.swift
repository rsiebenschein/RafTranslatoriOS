import Foundation
import Observation
import SwiftData

/// Drives the Settings screen: the editable settings draft, model discovery, usage summary, and
/// language add/edit/delete — mirroring the Android app's `SettingsScreen` state, minus the
/// accessibility-overlay section that stays out of scope for this phase.
@Observable
@MainActor
final class SettingsViewModel {
    var draft: SettingsData
    var usageSummary: UsageSummary = .empty

    var isFetchingModels = false
    var fetchModelsMessage: String?

    var newLanguageDraft = LanguageDraft()
    var isSavingLanguage = false
    var addLanguageMessage: String?

    var editingLanguage: LanguageDialect?
    var editingDraft = LanguageDraft()

    var saveConfirmationMessage: String?

    init(settings: SettingsData = AppSettings.load()) {
        self.draft = settings
    }

    func reload() {
        draft = AppSettings.load()
    }

    func loadUsageSummary(context: ModelContext) {
        usageSummary = (try? UsageRepository.summary(context: context)) ?? .empty
    }

    func save() {
        do {
            try AppSettings.save(draft)
            saveConfirmationMessage = "Settings saved successfully!"
        } catch {
            saveConfirmationMessage = "Couldn't save settings: \(error.localizedDescription)"
        }
    }

    func resetInstructions() {
        draft.instructions = AppSettings.defaultInstructions
    }

    func pasteApiKey(_ pasted: String) {
        draft.apiKey = pasted.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
