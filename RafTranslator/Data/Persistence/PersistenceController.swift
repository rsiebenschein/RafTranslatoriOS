import Foundation
import SwiftData

/// Owns the app's SwiftData container and runs first-launch/first-open seeding,
/// mirroring the Android app's `AppDatabase.getDatabase` create/open callbacks.
enum PersistenceController {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            LanguageDialect.self,
            GeminiModelRate.self,
            TranslationUsageRecord.self,
        ])
        let container = try ModelContainer(for: schema)
        try seedOnLaunch(container: container)
        return container
    }

    private static func seedOnLaunch(container: ModelContainer) throws {
        let context = ModelContext(container)
        try insertMissingPricingRates(context: context)
        try CatalogSeeding.seedIfNeeded(context: context)
    }

    private static func insertMissingPricingRates(context: ModelContext) throws {
        let existingIds = Set(try context.fetch(FetchDescriptor<GeminiModelRate>()).map(\.modelId))
        for rate in defaultPricingRates where !existingIds.contains(rate.modelId) {
            context.insert(rate)
        }
        try context.save()
    }

    /// Official Gemini API pricing rates per 1,000,000 tokens (USD).
    /// Sourced from Google's official Gemini developer pricing documentation.
    static var defaultPricingRates: [GeminiModelRate] {
        [
        GeminiModelRate(modelId: GeminiModelRate.fallbackRateId, displayName: "Standard Flash Baseline", inputCostPerMillion: 0.30, outputCostPerMillion: 2.50, cachedCostPerMillion: 0.03, source: "Google Gemini Official Pricing"),
        GeminiModelRate(modelId: "gemini-2.5-flash", displayName: "Gemini 2.5 Flash", inputCostPerMillion: 0.30, outputCostPerMillion: 2.50, cachedCostPerMillion: 0.03, source: "Google Gemini Official Pricing"),
        GeminiModelRate(modelId: "gemini-2.5-flash-lite", displayName: "Gemini 2.5 Flash-Lite", inputCostPerMillion: 0.10, outputCostPerMillion: 0.40, cachedCostPerMillion: 0.01, source: "Google Gemini Official Pricing"),
        GeminiModelRate(modelId: "gemini-flash-latest", displayName: "Gemini Flash Latest", inputCostPerMillion: 0.30, outputCostPerMillion: 2.50, cachedCostPerMillion: 0.03, source: "Google Gemini Official Pricing"),
        GeminiModelRate(modelId: "gemini-3.1-flash-lite", displayName: "Gemini 3.1 Flash-Lite", inputCostPerMillion: 0.25, outputCostPerMillion: 1.50, cachedCostPerMillion: 0.025, source: "Google Gemini Official Pricing"),
        GeminiModelRate(modelId: "gemini-3.5-flash", displayName: "Gemini 3.5 Flash", inputCostPerMillion: 1.50, outputCostPerMillion: 9.00, cachedCostPerMillion: 0.15, source: "Google Gemini Official Pricing"),
        ]
    }
}
