import Foundation

/// Active Flash/Flash-Lite model discovery for the Settings screen.
extension SettingsViewModel {
    @MainActor
    func fetchActiveModels() async {
        guard !draft.apiKey.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isFetchingModels = true
        fetchModelsMessage = nil
        defer { isFetchingModels = false }

        do {
            let models = try await GeminiService.fetchActiveFlashModels(apiKey: draft.apiKey)
            applyFetchedModels(models)
        } catch {
            fetchModelsMessage = "Error: \(error.localizedDescription)"
        }
    }

    private func applyFetchedModels(_ models: [GeminiModelItem]) {
        let modelIds = models.map(\.id)
        draft.availableModels = modelIds
        if !modelIds.contains(draft.selectedModel) {
            draft.selectedModel = modelIds.first ?? draft.selectedModel
        }
        try? AppSettings.updateAvailableModels(modelIds, selecting: draft.selectedModel)
        fetchModelsMessage = "Success: pulled \(modelIds.count) active Flash model(s)."
    }

    /// Display items for the model picker: live-fetched models when available, else the same
    /// fallback ids the app already ships with (mirrors Android's `DEFAULT_MODELS` placeholder).
    var modelsToDisplay: [GeminiModelItem] {
        guard !draft.availableModels.isEmpty else {
            return AppSettings.defaultModels.map {
                GeminiModelItem(id: $0, displayName: $0, description: "Active Flash Model")
            }
        }
        return draft.availableModels.map {
            GeminiModelItem(id: $0, displayName: $0, description: "Active Flash Model")
        }
    }
}
