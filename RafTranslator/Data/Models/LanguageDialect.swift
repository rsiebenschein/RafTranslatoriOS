import Foundation
import SwiftData

/// A single translatable language/dialect entry shown in the picker.
///
/// `seedKey`/`isUserModified` protect curated rows from `DialectSeeder`: once a user
/// edits a seed-originated row, the seeder must never overwrite it again.
@Model
final class LanguageDialect {
    /// Native prompt string sent to Gemini — kept stable, never renamed once shipped.
    var name: String
    var countryCode: String
    var flagEmoji: String
    var customIconUrl: String?
    var localImagePath: String?
    var isCustom: Bool
    var orderIndex: Int
    var languageNameEnglish: String
    var languageNameNative: String
    var countryNameEnglish: String
    var countryNameNative: String
    var seedKey: String?
    var isUserModified: Bool
    var searchKeywords: String
    var groupKey: String?
    var flatAssetUri: String?

    init(
        name: String,
        countryCode: String = "CH",
        flagEmoji: String = "🇨🇭",
        customIconUrl: String? = nil,
        localImagePath: String? = nil,
        isCustom: Bool = false,
        orderIndex: Int = 0,
        languageNameEnglish: String = "",
        languageNameNative: String = "",
        countryNameEnglish: String = "",
        countryNameNative: String = "",
        seedKey: String? = nil,
        isUserModified: Bool = false,
        searchKeywords: String = "",
        groupKey: String? = nil,
        flatAssetUri: String? = nil
    ) {
        self.name = name
        self.countryCode = countryCode
        self.flagEmoji = flagEmoji
        self.customIconUrl = customIconUrl
        self.localImagePath = localImagePath
        self.isCustom = isCustom
        self.orderIndex = orderIndex
        self.languageNameEnglish = languageNameEnglish
        self.languageNameNative = languageNameNative
        self.countryNameEnglish = countryNameEnglish
        self.countryNameNative = countryNameNative
        self.seedKey = seedKey
        self.isUserModified = isUserModified
        self.searchKeywords = searchKeywords
        self.groupKey = groupKey
        self.flatAssetUri = flatAssetUri
    }
}
