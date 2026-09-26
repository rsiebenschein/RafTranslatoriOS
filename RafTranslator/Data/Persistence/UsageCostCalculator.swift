import Foundation

/// USD cost of a single translation, split by input/output so callers can show either figure.
struct UsageCost {
    var inputUsd: Double
    var outputUsd: Double

    var totalUsd: Double { inputUsd + outputUsd }
}

/// The one place token counts become dollars. Cached prompt tokens are billed at the cached rate,
/// the rest of the prompt at the input rate, and thinking tokens at the output rate (Google bills
/// "output price including thinking tokens").
enum UsageCostCalculator {
    private static let tokensPerRateUnit = 1_000_000.0

    static func calculate(rate: GeminiModelRate, usage: TranslationResult) -> UsageCost {
        let uncachedPromptTokens = usage.promptTokenCount - usage.cachedContentTokenCount
        let billedOutputTokens = usage.candidatesTokenCount + usage.thoughtsTokenCount
        return UsageCost(
            inputUsd: cost(forTokens: uncachedPromptTokens, usdPerMillion: rate.inputCostPerMillion)
                + cost(forTokens: usage.cachedContentTokenCount, usdPerMillion: rate.cachedCostPerMillion),
            outputUsd: cost(forTokens: billedOutputTokens, usdPerMillion: rate.outputCostPerMillion)
        )
    }

    private static func cost(forTokens tokens: Int, usdPerMillion: Double) -> Double {
        Double(tokens) / tokensPerRateUnit * usdPerMillion
    }
}
