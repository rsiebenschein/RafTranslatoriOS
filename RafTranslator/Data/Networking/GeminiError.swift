import Foundation

/// Granular failure reasons for a Gemini API call, mirroring the Android client's
/// distinct `Result.failure` messages instead of one generic thrown error.
enum GeminiError: Error, LocalizedError {
    case missingAPIKey
    case emptyText
    case httpError(statusCode: Int, message: String)
    case responseBlocked(reason: String)
    case noCandidatesReturned
    case emptyContentParts
    case malformedResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Please configure your Gemini API Key in Settings first."
        case .emptyText:
            return "Text to translate cannot be empty."
        case .httpError(let statusCode, let message):
            return "Gemini API Error (\(statusCode)): \(message)"
        case .responseBlocked(let reason):
            return "Response blocked: \(reason)"
        case .noCandidatesReturned:
            return "No translation returned by Gemini."
        case .emptyContentParts:
            return "Model returned empty content parts."
        case .malformedResponse:
            return "Gemini returned a response that could not be parsed."
        }
    }
}
