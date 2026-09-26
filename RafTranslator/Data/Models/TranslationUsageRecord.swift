import Foundation
import SwiftData

/// A logged record of token usage and cost for a single successful translation.
@Model
final class TranslationUsageRecord {
    var timestamp: Date
    var model: String
    var targetLanguage: String
    var promptTokens: Int
    var candidateTokens: Int
    /// Invisible thinking tokens, billed at the output rate.
    var thoughtsTokens: Int
    var cachedPromptTokens: Int
    var totalTokens: Int
    var inputCostUsd: Double
    var outputCostUsd: Double
    var totalCostUsd: Double
    var textSnippet: String

    init(
        timestamp: Date = .now,
        model: String,
        targetLanguage: String,
        promptTokens: Int,
        candidateTokens: Int,
        thoughtsTokens: Int = 0,
        cachedPromptTokens: Int = 0,
        totalTokens: Int,
        inputCostUsd: Double,
        outputCostUsd: Double,
        totalCostUsd: Double,
        textSnippet: String = ""
    ) {
        self.timestamp = timestamp
        self.model = model
        self.targetLanguage = targetLanguage
        self.promptTokens = promptTokens
        self.candidateTokens = candidateTokens
        self.thoughtsTokens = thoughtsTokens
        self.cachedPromptTokens = cachedPromptTokens
        self.totalTokens = totalTokens
        self.inputCostUsd = inputCostUsd
        self.outputCostUsd = outputCostUsd
        self.totalCostUsd = totalCostUsd
        self.textSnippet = textSnippet
    }
}
