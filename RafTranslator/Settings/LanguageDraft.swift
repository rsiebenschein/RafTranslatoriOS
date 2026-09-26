import Foundation

/// In-progress form state for adding or editing a `LanguageDialect`. iOS has no bundled SVG flag
/// library to mirror the Android app's asset picker, so the flag is a plain emoji field instead —
/// the native, dependency-free equivalent.
struct LanguageDraft: Equatable {
    var name: String = ""
    var countryCode: String = ""
    var flagEmoji: String = "🏳️"
    var searchKeywords: String = ""

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    static func from(_ dialect: LanguageDialect) -> LanguageDraft {
        LanguageDraft(
            name: dialect.name,
            countryCode: dialect.countryCode,
            flagEmoji: dialect.flagEmoji,
            searchKeywords: dialect.searchKeywords
        )
    }

    func apply(to dialect: LanguageDialect) {
        dialect.name = name.trimmingCharacters(in: .whitespaces)
        dialect.countryCode = countryCode.trimmingCharacters(in: .whitespaces).uppercased()
        dialect.flagEmoji = flagEmoji
        dialect.searchKeywords = searchKeywords.trimmingCharacters(in: .whitespaces)
        dialect.isUserModified = true
    }
}
