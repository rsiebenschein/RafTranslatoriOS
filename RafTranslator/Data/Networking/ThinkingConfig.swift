import Foundation

/// Translation gains nothing from reasoning, but thought tokens cost output-rate money and add
/// latency. The field that limits thinking depends on the model generation, and the API rejects
/// the wrong one: 2.5 takes `thinkingBudget` (0 = off), 3.x takes `thinkingLevel` (and errors on
/// `thinkingBudget`).
///
/// `ThinkingLevel`'s documented enum is UNSPECIFIED / MINIMAL / LOW / MEDIUM / HIGH, but MINIMAL
/// was tried on a real 3.8 model on-device (2026-09-22) and rejected outright ("thinking level
/// minimal is not supported for this model") — documented as valid is not the same as accepted by
/// every model that reports itself as 3.x. Kept at "low", the value the Android client shipped
/// with and confirmed working. Do not change this again without an on-device check against the
/// actual model in use, not just the API reference.
enum ThinkingConfig {
    private static var modelVersionPattern: Regex<(Substring, Substring)> { #/^gemini-(\d+(?:\.\d+)?)-/# }
    private static let firstThinkingLevelVersion = 3.0
    private static let thinkingBudgetVersion = 2.5

    /// The single thinkingConfig field/value pair to send, or nil when the model's generation is
    /// unknown (e.g. the moving `gemini-flash-latest` alias): safer to send nothing.
    static func forModel(_ modelId: String) -> (field: String, value: ThinkingFieldValue)? {
        let id = modelId.hasPrefix("models/") ? String(modelId.dropFirst("models/".count)) : modelId
        guard let version = parsedVersion(from: id), !id.contains("pro") else { return nil }

        if version >= firstThinkingLevelVersion {
            return ("thinkingLevel", .string("low"))
        }
        if version == thinkingBudgetVersion {
            return ("thinkingBudget", .int(0))
        }
        return nil
    }

    private static func parsedVersion(from modelId: String) -> Double? {
        guard let match = modelId.firstMatch(of: modelVersionPattern) else { return nil }
        return Double(match.1)
    }
}

/// Encodable wrapper since `thinkingConfig`'s single field can be either a string or an int.
enum ThinkingFieldValue: Encodable {
    case string(String)
    case int(Int)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        }
    }
}
