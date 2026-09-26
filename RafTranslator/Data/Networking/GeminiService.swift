import Foundation

/// REST client for the Gemini `generativelanguage.googleapis.com/v1beta` API: translation via
/// `generateContent`, active-model discovery via `GET /models`, and shared retry/backoff.
/// Stateless by design, mirroring the Android `GeminiService` singleton object.
enum GeminiService {
    static let apiBaseURL = URL(string: "https://generativelanguage.googleapis.com/v1beta")!
    static let apiKeyHeader = "x-goog-api-key"

    /// Models to fall back to if a live `/models` fetch returns nothing eligible.
    static let fallbackModelIds = [
        "gemini-2.5-flash-lite",
        "gemini-2.5-flash",
        "gemini-3.1-flash-lite",
        "gemini-3.5-flash",
        "gemini-flash-latest",
    ]

    /// Shorter timeouts for the interactive translate tap — a long hang on a flaky connection
    /// leaves the user staring at a spinner with no way to cancel. The model-list fetch uses the
    /// more patient `listSession` below.
    static let translateSession: URLSession = makeSession(timeout: 20)
    static let listSession: URLSession = makeSession(timeout: 60)

    private static func makeSession(timeout: TimeInterval) -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        return URLSession(configuration: configuration)
    }

    /// Fetches active Flash and Flash-Lite text models from the Gemini API. Strictly filters out
    /// deprecated (1.5/2.0), Pro, image, audio/TTS, and embedding models, and anything not
    /// supporting `generateContent`.
    static func fetchActiveFlashModels(apiKey: String) async throws -> [GeminiModelItem] {
        guard !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw GeminiError.missingAPIKey
        }

        let url = apiBaseURL.appendingPathComponent("models")
        let request = authorizedRequest(url: url, apiKey: apiKey)
        let body = try await executeWithRetry(session: listSession, request: request)

        let listResponse = try decode(ModelsListResponse.self, from: body)
        let filtered = filterFlashModels(listResponse.models ?? [])
        return filtered.isEmpty ? fallbackModelList() : sortedByPreference(filtered)
    }

    private static func fallbackModelList() -> [GeminiModelItem] {
        fallbackModelIds.map { GeminiModelItem(id: $0, displayName: $0, description: "Active Flash Model") }
    }

    /// Generates a dialect translation via the Gemini REST API. Replaces `{{language}}` in
    /// `instructionsTemplate` and formats the request body.
    static func translateText(
        apiKey: String,
        model: String,
        instructionsTemplate: String,
        targetLanguage: String,
        textToTranslate: String
    ) async throws -> TranslationResult {
        guard !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw GeminiError.missingAPIKey
        }
        guard !textToTranslate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeminiError.emptyText
        }

        let cleanModel = model.hasPrefix("models/") ? String(model.dropFirst("models/".count)) : model
        let request = try buildTranslateRequest(
            apiKey: apiKey,
            cleanModel: cleanModel,
            instructionsTemplate: instructionsTemplate,
            targetLanguage: targetLanguage,
            textToTranslate: textToTranslate
        )
        let body = try await executeWithRetry(session: translateSession, request: request)
        return try parseTranslationResponse(body)
    }

    /// Opens the TCP+TLS connection to the Gemini host ahead of the user's first tap. No API key
    /// is needed — a 401 still means the socket and handshake are ready, and the real request
    /// later reuses the pooled connection instead of paying that cost again.
    static func warmConnection() async {
        var request = URLRequest(url: apiBaseURL)
        request.httpMethod = "HEAD"
        _ = try? await translateSession.data(for: request)
    }

    /// The key goes in a header, not the query string: URLs are what end up in proxy logs and
    /// crash reports.
    static func authorizedRequest(url: URL, apiKey: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue(apiKey.trimmingCharacters(in: .whitespaces), forHTTPHeaderField: apiKeyHeader)
        return request
    }
}
