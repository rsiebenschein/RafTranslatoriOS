import Foundation
import SwiftData

/// Official Gemini API pricing for a single model, in USD per 1,000,000 tokens.
@Model
final class GeminiModelRate {
    @Attribute(.unique) var modelId: String
    var displayName: String
    var inputCostPerMillion: Double
    var outputCostPerMillion: Double
    var cachedCostPerMillion: Double
    var lastUpdated: Date
    var source: String

    init(
        modelId: String,
        displayName: String,
        inputCostPerMillion: Double,
        outputCostPerMillion: Double,
        cachedCostPerMillion: Double = 0.0,
        lastUpdated: Date = .now,
        source: String = "Google Gemini Official Rates"
    ) {
        self.modelId = modelId
        self.displayName = displayName
        self.inputCostPerMillion = inputCostPerMillion
        self.outputCostPerMillion = outputCostPerMillion
        self.cachedCostPerMillion = cachedCostPerMillion
        self.lastUpdated = lastUpdated
        self.source = source
    }

    static let fallbackRateId = "default"
}
