import Foundation

/// The full set of persisted user settings, mirroring the Android app's `SettingsData`.
struct SettingsData: Equatable {
    var apiKey: String
    var selectedModel: String
    var availableModels: [String]
    var targetLanguage: String
    var instructions: String
}

/// Settings keys and load/save logic. The API key lives in the Keychain; everything else lives
/// in `UserDefaults` — an improvement over the Android app's known plaintext-SharedPreferences
/// storage of the API key.
enum AppSettings {
    static let defaultModels = GeminiService.fallbackModelIds

    /// Flash-Lite: thinking off by the API's own default for the 2.5 generation, and
    /// substantially cheaper than 2.5 Flash per Google's official per-token pricing. See
    /// `ThinkingConfig` for why `gemini-3.1-flash-lite` is not the default despite the newer
    /// generation: its thinking floor is not confirmed off.
    static let defaultModel = "gemini-2.5-flash-lite"

    static let defaultLanguage = "Schwizerdütsch - Zürcher Dialekt"

    static let defaultInstructions = """
    You are an expert dialect and language translator.
    Translate the given text into authentic, natural, colloquial {{language}}.

    CRITICAL RULES:
    1. Output ONLY the direct translation.
    2. Never include ANY explanation, notes, greeting, phonetic transcriptions, disclaimers, or markdown commentary.
    3. Preserve the natural conversational tone, authentic vocabulary, and everyday spelling conventions of the dialect.
    4. Do NOT translate into standard High German (Hochdeutsch) unless explicitly requested.
    5. Translate profanity, swearing, and explicit language literally and directly, with the same force and register as the source — never soften, censor, euphemize, or tone it down. The user chose the words; your job is an accurate translation, not moderation.
    """

    private static let apiKeyAccount = "gemini_api_key"

    private enum DefaultsKey {
        static let selectedModel = "selected_model"
        static let availableModels = "available_models"
        static let targetLanguage = "target_language"
        static let instructions = "instructions"
    }

    static func load(defaults: UserDefaults = .standard) -> SettingsData {
        let apiKey = (try? KeychainStore.load(account: apiKeyAccount)).flatMap { $0 } ?? ""
        let availableModels = defaults.stringArray(forKey: DefaultsKey.availableModels) ?? defaultModels
        let selectedModel = defaults.string(forKey: DefaultsKey.selectedModel) ?? defaultModel

        return SettingsData(
            apiKey: apiKey,
            selectedModel: availableModels.contains(selectedModel) ? selectedModel : (availableModels.first ?? defaultModel),
            availableModels: availableModels,
            targetLanguage: defaults.string(forKey: DefaultsKey.targetLanguage) ?? defaultLanguage,
            instructions: defaults.string(forKey: DefaultsKey.instructions) ?? defaultInstructions
        )
    }

    static func save(_ settings: SettingsData, defaults: UserDefaults = .standard) throws {
        try KeychainStore.save(settings.apiKey.trimmingCharacters(in: .whitespaces), account: apiKeyAccount)
        defaults.set(settings.selectedModel.trimmingCharacters(in: .whitespaces), forKey: DefaultsKey.selectedModel)
        defaults.set(settings.availableModels, forKey: DefaultsKey.availableModels)
        defaults.set(settings.targetLanguage.trimmingCharacters(in: .whitespaces), forKey: DefaultsKey.targetLanguage)
        defaults.set(settings.instructions.trimmingCharacters(in: .whitespaces), forKey: DefaultsKey.instructions)
    }

    /// Persists a freshly fetched active-models list, clamping the selected model to it exactly
    /// as the Android app's `updateAvailableModels` does.
    static func updateAvailableModels(
        _ models: [String],
        selecting explicitModel: String? = nil,
        defaults: UserDefaults = .standard
    ) throws {
        var current = load(defaults: defaults)
        let newSelected = explicitModel ?? (models.contains(current.selectedModel) ? current.selectedModel : (models.first ?? current.selectedModel))
        current.availableModels = models
        current.selectedModel = newSelected
        try save(current, defaults: defaults)
    }
}
