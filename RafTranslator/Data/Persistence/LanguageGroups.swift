import Foundation

/// Display metadata for a language "group" shown as an expandable node in the
/// Settings dialect picker (e.g. German -> Bavarian/Swabian/..., or the promoted
/// Indian Languages / Swiss German / Arabic / South African / Nigerian clusters).
/// A `LanguageDialect` row opts into a group via its `groupKey` field.
struct LanguageGroupInfo {
    let key: String
    let labelEnglish: String
    let labelNative: String
    let assetCode: String
    let flagEmoji: String
}

enum LanguageGroups {
    static let all: [LanguageGroupInfo] = [
        LanguageGroupInfo(key: "english", labelEnglish: "English", labelNative: "English", assetCode: "gb", flagEmoji: "🇬🇧"),
        LanguageGroupInfo(key: "french", labelEnglish: "French", labelNative: "Français", assetCode: "fr", flagEmoji: "🇫🇷"),
        LanguageGroupInfo(key: "german", labelEnglish: "German", labelNative: "Deutsch", assetCode: "de", flagEmoji: "🇩🇪"),
        LanguageGroupInfo(key: "swiss-german", labelEnglish: "Swiss German", labelNative: "Schwizerdütsch", assetCode: "ch", flagEmoji: "🇨🇭"),
        LanguageGroupInfo(key: "italian", labelEnglish: "Italian", labelNative: "Italiano", assetCode: "it", flagEmoji: "🇮🇹"),
        LanguageGroupInfo(key: "spanish", labelEnglish: "Spanish", labelNative: "Español", assetCode: "es", flagEmoji: "🇪🇸"),
        LanguageGroupInfo(key: "greek", labelEnglish: "Greek", labelNative: "Ελληνικά", assetCode: "gr", flagEmoji: "🇬🇷"),
        LanguageGroupInfo(key: "arabic", labelEnglish: "Arabic", labelNative: "العربية", assetCode: "sa", flagEmoji: "🇸🇦"),
        LanguageGroupInfo(key: "indian-languages", labelEnglish: "Indian Languages", labelNative: "भारतीय भाषाएँ", assetCode: "in", flagEmoji: "🇮🇳"),
        LanguageGroupInfo(key: "south-african-languages", labelEnglish: "South African Languages", labelNative: "South African Languages", assetCode: "za", flagEmoji: "🇿🇦"),
        LanguageGroupInfo(key: "nigerian-languages", labelEnglish: "Nigerian Languages", labelNative: "Nigerian Languages", assetCode: "ng", flagEmoji: "🇳🇬"),
        LanguageGroupInfo(key: "congolese-languages", labelEnglish: "Congolese Languages", labelNative: "Congolese Languages", assetCode: "cd", flagEmoji: "🇨🇩"),
    ]

    private static let byKey = Dictionary(uniqueKeysWithValues: all.map { ($0.key, $0) })

    static func info(forKey key: String?) -> LanguageGroupInfo? {
        guard let key else { return nil }
        return byKey[key]
    }
}
