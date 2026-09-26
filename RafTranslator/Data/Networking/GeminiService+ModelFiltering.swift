import Foundation

/// Filtering and preference-ordering for `GET /models` results.
extension GeminiService {
    private static var modelVersionPattern: Regex<(Substring, Substring, Substring)> { #/gemini-(\d+)\.(\d+)/# }
    private static let oldestSupportedVersion = (major: 2, minor: 5)

    static func filterFlashModels(_ models: [ModelInfo]) -> [GeminiModelItem] {
        models
            .filter { supportsGenerateContent($0) }
            .compactMap { flashModelItemOrNil($0) }
    }

    private static func supportsGenerateContent(_ model: ModelInfo) -> Bool {
        model.supportedGenerationMethods?.contains("generateContent") ?? false
    }

    /// Nil unless the model is a non-deprecated, non-Pro Flash/Flash-Lite text model.
    private static func flashModelItemOrNil(_ model: ModelInfo) -> GeminiModelItem? {
        let rawName = model.name ?? ""
        let displayName = model.displayName ?? ""
        let cleanId = rawName.hasPrefix("models/") ? String(rawName.dropFirst("models/".count)) : rawName
        let lowerId = cleanId.lowercased()
        let lowerName = displayName.lowercased()

        let isFlash = lowerId.contains("flash") || lowerName.contains("flash")
        guard isFlash, !isExcludedFlashVariant(lowerId) else { return nil }

        return GeminiModelItem(
            id: cleanId,
            displayName: displayName.isEmpty ? cleanId : displayName,
            description: model.description ?? ""
        )
    }

    /// Old/deprecated, image, audio, embedding, thinking-preview, realtime and Pro variants are
    /// not eligible.
    private static func isExcludedFlashVariant(_ lowerId: String) -> Bool {
        isDeprecatedGeminiVersion(lowerId)
            || lowerId.contains("image") || lowerId.contains("imagen")
            || lowerId.contains("audio") || lowerId.contains("tts")
            || lowerId.contains("embed") || lowerId.contains("thinking")
            || lowerId.contains("realtime") || lowerId.contains("pro")
    }

    /// Newest non-lite version first, then the unversioned "-latest" alias, then lite variants
    /// by version.
    static func sortedByPreference(_ models: [GeminiModelItem]) -> [GeminiModelItem] {
        models.sorted { lhs, rhs in
            sortKey(for: lhs).lexicographicallyPrecedes(sortKey(for: rhs))
        }
    }

    private static func sortKey(for item: GeminiModelItem) -> [Int] {
        let lowerId = item.id.lowercased()
        let version = parseGeminiVersion(lowerId)
        return [
            lowerId.contains("lite") ? 1 : 0,
            version == nil ? 1 : 0,
            -(version?.major ?? 0),
            -(version?.minor ?? 0),
        ]
    }

    /// Extracts the "X.Y" version from a model id like "gemini-2.5-flash", or nil for unversioned
    /// aliases.
    static func parseGeminiVersion(_ modelId: String) -> (major: Int, minor: Int)? {
        guard let match = modelId.firstMatch(of: modelVersionPattern),
              let major = Int(match.1), let minor = Int(match.2) else { return nil }
        return (major, minor)
    }

    /// True for versions strictly older than `oldestSupportedVersion` (e.g. 1.5, 2.0) — never
    /// for unversioned aliases.
    static func isDeprecatedGeminiVersion(_ modelId: String) -> Bool {
        guard let version = parseGeminiVersion(modelId) else { return false }
        return version.major < oldestSupportedVersion.major
            || (version.major == oldestSupportedVersion.major && version.minor < oldestSupportedVersion.minor)
    }
}
