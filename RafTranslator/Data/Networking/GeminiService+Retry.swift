import Foundation

/// Shared retry/backoff and error-decoding used by both `fetchActiveFlashModels` and
/// `translateText`.
extension GeminiService {
    private static let retryableStatusCodes: Set<Int> = [429, 500, 503]
    private static let maxRetryAttempts = 2 // up to 3 total attempts
    private static let baseBackoffMs = 500
    private static let maxJitterMs = 250
    private static var retryDelayPattern: Regex<(Substring, Substring)> { #/"retryDelay"\s*:\s*"(\d+(?:\.\d+)?)s"/# }

    /// Runs `request` against `session`, retrying on 429/500/503 up to `maxRetryAttempts` more
    /// times. Honors the API's own `retryDelay` (e.g. "35s") from the error body when present,
    /// otherwise backs off exponentially with jitter. Any other status is returned as the body
    /// for the caller to turn into a `GeminiError.httpError`.
    static func executeWithRetry(session: URLSession, request: URLRequest) async throws -> Data {
        var attempt = 0
        while true {
            let (data, statusCode) = try await performCall(session: session, request: request)
            if statusCode >= 200 && statusCode <= 299 { return data }
            guard retryableStatusCodes.contains(statusCode), attempt < maxRetryAttempts else {
                throw GeminiError.httpError(statusCode: statusCode, message: extractErrorMessage(data))
            }
            try await Task.sleep(nanoseconds: retryDelayNanoseconds(attempt: attempt, errorBody: data))
            attempt += 1
        }
    }

    private static func performCall(session: URLSession, request: URLRequest) async throws -> (Data, Int) {
        let (data, response) = try await session.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        return (data, statusCode)
    }

    /// The delay before retry attempt `attempt` (0-indexed): the server's own `retryDelay` if the
    /// error body carries one, else exponential backoff with jitter.
    static func retryDelayNanoseconds(attempt: Int, errorBody: Data) -> UInt64 {
        if let seconds = parseRetryDelaySeconds(errorBody) {
            return UInt64(seconds * 1_000_000_000)
        }
        return computeBackoffDelayMillis(attempt: attempt) * 1_000_000
    }

    static func parseRetryDelaySeconds(_ errorBody: Data) -> Double? {
        guard let text = String(data: errorBody, encoding: .utf8),
              let match = text.firstMatch(of: retryDelayPattern) else { return nil }
        return Double(match.1)
    }

    static func computeBackoffDelayMillis(attempt: Int) -> UInt64 {
        UInt64(baseBackoffMs << attempt) + UInt64.random(in: 0..<UInt64(maxJitterMs))
    }

    static func extractErrorMessage(_ body: Data) -> String {
        (try? JSONDecoder().decode(APIErrorEnvelope.self, from: body))?.error?.message ?? "Unknown error"
    }

    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw GeminiError.malformedResponse
        }
    }
}
