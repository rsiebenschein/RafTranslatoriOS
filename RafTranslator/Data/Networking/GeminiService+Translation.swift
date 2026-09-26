import Foundation

/// Request building and response parsing for `translateText`.
extension GeminiService {
    private static let charsPerTokenEstimate = 4
    private static let outputTokenMultiplier = 4
    private static let outputTokenPad = 64
    private static let thinkingActiveMinOutputTokens = 1024
    private static let safetyCategories = [
        "HARM_CATEGORY_HARASSMENT",
        "HARM_CATEGORY_HATE_SPEECH",
        "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "HARM_CATEGORY_DANGEROUS_CONTENT",
    ]

    static func buildTranslateRequest(
        apiKey: String,
        cleanModel: String,
        instructionsTemplate: String,
        targetLanguage: String,
        textToTranslate: String
    ) throws -> URLRequest {
        let resolvedInstructions = instructionsTemplate.replacingOccurrences(
            of: "{{language}}", with: targetLanguage.trimmingCharacters(in: .whitespaces)
        )
        let payload = GenerateContentRequest(
            systemInstruction: TextContent(text: resolvedInstructions),
            contents: [userTurn(targetLanguage: targetLanguage, textToTranslate: textToTranslate)],
            generationConfig: buildGenerationConfig(model: cleanModel, textToTranslate: textToTranslate),
            safetySettings: buildSafetySettings()
        )

        let url = apiBaseURL.appendingPathComponent("models/\(cleanModel):generateContent")
        var request = authorizedRequest(url: url, apiKey: apiKey)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        return request
    }

    private static func userTurn(targetLanguage: String, textToTranslate: String) -> TextContent {
        TextContent(text: """
        Text to translate:
        \"\"\"
        \(textToTranslate)
        \"\"\"

        Translate strictly into \(targetLanguage) without any explanations:
        """)
    }

    /// Literal translation is the whole point of this app, so profanity or explicit source text
    /// must not be softened or blocked by default.
    static func buildSafetySettings() -> [SafetySetting] {
        safetyCategories.map { SafetySetting(category: $0, threshold: "BLOCK_NONE") }
    }

    static func buildGenerationConfig(model: String, textToTranslate: String) -> GenerationConfig {
        let thinking = ThinkingConfig.forModel(model)
        let thinkingFullyOff = thinking?.field == "thinkingBudget" && isZero(thinking?.value)
        return GenerationConfig(
            temperature: 0.2,
            maxOutputTokens: estimateMaxOutputTokens(textToTranslate, thinkingFullyOff: thinkingFullyOff),
            thinkingConfig: thinking.map { [$0.field: $0.value] }
        )
    }

    private static func isZero(_ value: ThinkingFieldValue?) -> Bool {
        if case .int(0) = value { return true }
        return false
    }

    /// A dialect translation is roughly the same length as its source, so bound the output at
    /// ~4x the source's estimated token count plus a fixed pad, instead of leaving it unbounded.
    /// Only safe to size tightly to the text when thinking is fully off; every other model needs
    /// headroom since reasoning tokens can eat into this budget before any output text is written.
    static func estimateMaxOutputTokens(_ textToTranslate: String, thinkingFullyOff: Bool) -> Int {
        let estimatedInputTokens = (textToTranslate.count / charsPerTokenEstimate) + 1
        let textBasedCap = estimatedInputTokens * outputTokenMultiplier + outputTokenPad
        return thinkingFullyOff ? textBasedCap : max(textBasedCap, thinkingActiveMinOutputTokens)
    }

    static func parseTranslationResponse(_ body: Data) throws -> TranslationResult {
        let response = try decode(GenerateContentResponse.self, from: body)

        guard let candidates = response.candidates, !candidates.isEmpty else {
            if let blockReason = response.promptFeedback?.blockReason, !blockReason.isEmpty {
                throw GeminiError.responseBlocked(reason: blockReason)
            }
            throw GeminiError.noCandidatesReturned
        }
        guard let parts = candidates[0].content?.parts, !parts.isEmpty else {
            throw GeminiError.emptyContentParts
        }

        let usage = response.usageMetadata
        return TranslationResult(
            text: extractResultText(parts),
            promptTokenCount: usage?.promptTokenCount ?? 0,
            candidatesTokenCount: usage?.candidatesTokenCount ?? 0,
            thoughtsTokenCount: usage?.thoughtsTokenCount ?? 0,
            totalTokenCount: usage?.totalTokenCount ?? 0,
            cachedContentTokenCount: usage?.cachedContentTokenCount ?? 0
        )
    }

    /// Concatenates the response's text parts and strips a wrapping pair of quotes the model
    /// sometimes adds.
    private static func extractResultText(_ parts: [TextPart]) -> String {
        let combined = parts.map(\.text).joined()
        let trimmed = combined.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count >= 2, trimmed.hasPrefix("\""), trimmed.hasSuffix("\"") {
            return String(trimmed.dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return trimmed
    }
}
