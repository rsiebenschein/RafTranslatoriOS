import Foundation
import Observation
import SwiftData

/// Drives the main translate screen: current settings, input/output text, and the dictation
/// session. Mirrors the Android app's `MainViewModel`, minus the accessibility-overlay and
/// language-management state that belongs to later steps.
@Observable
@MainActor
final class TranslateViewModel {
    var settings: SettingsData
    var inputText = ""
    var isTranslating = false
    var translationResult: TranslationResult?
    var translationError: String?
    var isCopied = false

    let dictation = DictationService()

    init(settings: SettingsData = AppSettings.load()) {
        self.settings = settings
    }

    func reloadSettings() {
        settings = AppSettings.load()
    }

    func clearInput() {
        inputText = ""
        translationResult = nil
        translationError = nil
    }

    @MainActor
    func translate(modelContext: ModelContext) async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isTranslating else { return }

        isTranslating = true
        translationError = nil
        defer { isTranslating = false }

        do {
            let result = try await GeminiService.translateText(
                apiKey: settings.apiKey,
                model: settings.selectedModel,
                instructionsTemplate: settings.instructions,
                targetLanguage: settings.targetLanguage,
                textToTranslate: text
            )
            translationResult = result
            _ = try? UsageRepository.recordUsage(
                model: settings.selectedModel,
                targetLanguage: settings.targetLanguage,
                translation: result,
                context: modelContext
            )
        } catch {
            translationError = error.localizedDescription
        }
    }
}
