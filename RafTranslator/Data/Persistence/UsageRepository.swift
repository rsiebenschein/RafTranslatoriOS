import Foundation
import SwiftData

/// Aggregate token/cost totals across every logged translation, mirroring the Android app's
/// `UsageSummary` Room projection.
struct UsageSummary {
    var totalRequests: Int
    var grandTotalTokens: Int
    var grandTotalCostUsd: Double

    static let empty = UsageSummary(totalRequests: 0, grandTotalTokens: 0, grandTotalCostUsd: 0)

    var averageCostUsd: Double {
        totalRequests > 0 ? grandTotalCostUsd / Double(totalRequests) : 0
    }
}

/// Logs per-translation token/cost usage and answers the Settings screen's usage-and-billing
/// questions, mirroring the Android app's `UsageRepository` + `AppDatabase` pricing table.
enum UsageRepository {
    private static let snippetLength = 50

    /// Persists the usage of one translation and returns the record, so callers show exactly what
    /// was stored. Pass `recordSnippet: false` when the text belongs to someone else, so none of
    /// it is kept on the device.
    @discardableResult
    static func recordUsage(
        model: String,
        targetLanguage: String,
        translation: TranslationResult,
        recordSnippet: Bool = true,
        context: ModelContext
    ) throws -> TranslationUsageRecord {
        let rate = try resolveRate(forModel: model, context: context)
        let cost = UsageCostCalculator.calculate(rate: rate, usage: translation)
        let record = TranslationUsageRecord(
            model: model,
            targetLanguage: targetLanguage,
            promptTokens: translation.promptTokenCount,
            candidateTokens: translation.candidatesTokenCount,
            thoughtsTokens: translation.thoughtsTokenCount,
            cachedPromptTokens: translation.cachedContentTokenCount,
            totalTokens: translation.totalTokenCount,
            inputCostUsd: cost.inputUsd,
            outputCostUsd: cost.outputUsd,
            totalCostUsd: cost.totalUsd,
            textSnippet: recordSnippet ? String(translation.text.prefix(snippetLength)) : ""
        )
        context.insert(record)
        try context.save()
        return record
    }

    static func summary(context: ModelContext) throws -> UsageSummary {
        let records = try context.fetch(FetchDescriptor<TranslationUsageRecord>())
        guard !records.isEmpty else { return .empty }
        return UsageSummary(
            totalRequests: records.count,
            grandTotalTokens: records.reduce(0) { $0 + $1.totalTokens },
            grandTotalCostUsd: records.reduce(0) { $0 + $1.totalCostUsd }
        )
    }

    static func clearHistory(context: ModelContext) throws {
        for record in try context.fetch(FetchDescriptor<TranslationUsageRecord>()) {
            context.delete(record)
        }
        try context.save()
    }

    /// Re-applies the bundled pricing table over whatever rates are already stored, for when
    /// Google's published pricing changes between app updates.
    static func refreshDefaultRates(context: ModelContext) throws {
        let existingByModelId = Dictionary(
            uniqueKeysWithValues: try context.fetch(FetchDescriptor<GeminiModelRate>()).map { ($0.modelId, $0) }
        )
        for defaultRate in PersistenceController.defaultPricingRates {
            if let existing = existingByModelId[defaultRate.modelId] {
                applyRate(defaultRate, to: existing)
            } else {
                context.insert(defaultRate)
            }
        }
        try context.save()
    }

    private static func applyRate(_ source: GeminiModelRate, to target: GeminiModelRate) {
        target.displayName = source.displayName
        target.inputCostPerMillion = source.inputCostPerMillion
        target.outputCostPerMillion = source.outputCostPerMillion
        target.cachedCostPerMillion = source.cachedCostPerMillion
        target.lastUpdated = source.lastUpdated
        target.source = source.source
    }

    private static func resolveRate(forModel model: String, context: ModelContext) throws -> GeminiModelRate {
        if let rate = try firstRate(matchingModelId: model, context: context) {
            return rate
        }
        if let fallback = try firstRate(matchingModelId: GeminiModelRate.fallbackRateId, context: context) {
            return fallback
        }
        return PersistenceController.defaultPricingRates.first { $0.modelId == GeminiModelRate.fallbackRateId }!
    }

    private static func firstRate(matchingModelId modelId: String, context: ModelContext) throws -> GeminiModelRate? {
        var descriptor = FetchDescriptor<GeminiModelRate>(predicate: #Predicate { $0.modelId == modelId })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
