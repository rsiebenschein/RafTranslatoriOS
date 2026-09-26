import Foundation

/// A Gemini text-generation model returned by `GET /models`, filtered to Flash/Flash-Lite.
struct GeminiModelItem: Identifiable, Equatable {
    var id: String // e.g. "gemini-2.5-flash"
    var displayName: String
    var description: String
}

/// The successful result of a single `generateContent` translation call.
struct TranslationResult {
    var text: String
    var promptTokenCount: Int
    var candidatesTokenCount: Int
    var thoughtsTokenCount: Int
    var totalTokenCount: Int
    var cachedContentTokenCount: Int
}

// MARK: - Request payload

struct GenerateContentRequest: Encodable {
    var systemInstruction: TextContent
    var contents: [TextContent]
    var generationConfig: GenerationConfig
    var safetySettings: [SafetySetting]
}

struct TextContent: Encodable {
    var parts: [TextPart]

    init(text: String) {
        self.parts = [TextPart(text: text)]
    }
}

struct TextPart: Codable {
    var text: String
}

struct GenerationConfig: Encodable {
    var temperature: Double
    var maxOutputTokens: Int
    var thinkingConfig: [String: ThinkingFieldValue]?
}

struct SafetySetting: Encodable {
    var category: String
    var threshold: String
}

// MARK: - Response payload

struct GenerateContentResponse: Decodable {
    var candidates: [Candidate]?
    var usageMetadata: UsageMetadata?
    var promptFeedback: PromptFeedback?
}

struct Candidate: Decodable {
    var content: ContentParts?
}

struct ContentParts: Decodable {
    var parts: [TextPart]?
}

struct UsageMetadata: Decodable {
    var promptTokenCount: Int?
    var candidatesTokenCount: Int?
    var thoughtsTokenCount: Int?
    var totalTokenCount: Int?
    var cachedContentTokenCount: Int?
}

struct PromptFeedback: Decodable {
    var blockReason: String?
}

struct ModelsListResponse: Decodable {
    var models: [ModelInfo]?
}

struct ModelInfo: Decodable {
    var name: String?
    var displayName: String?
    var description: String?
    var supportedGenerationMethods: [String]?
}

struct APIErrorEnvelope: Decodable {
    var error: APIErrorDetail?
}

struct APIErrorDetail: Decodable {
    var message: String?
}
