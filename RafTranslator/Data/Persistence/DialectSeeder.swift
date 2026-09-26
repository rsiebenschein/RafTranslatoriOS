import Foundation
import SwiftData

/// Populates and keeps the language/dialect catalog in sync across app updates.
///
/// Design reference: ported from the Android app's DialectSeeder.kt / Languages-README.md
/// (grouping model, the "would Gemini write different text" rule, and why seedKey/isUserModified exist).
enum DialectSeeder {

    struct SeedDialect {
        let seedKey: String
        let groupKey: String?
        let countryCode: String
        let flagEmoji: String
        let assetCode: String
        let countryNameEnglish: String
        let countryNameNative: String
        let dialectNameEnglish: String
        let dialectNameNative: String
        /// Sent to Gemini — kept stable, never renamed once shipped.
        let promptName: String
        let searchKeywords: [String]
    }

    static func flatAssetUri(forAssetCode assetCode: String) -> String {
        "flags/flag/\(assetCode).svg"
    }

    /// Bump whenever the bundled round asset artwork changes, to bust any cached bubble icon.
    private static let roundAssetVersion = "v7"

    static func roundAssetUri(forAssetCode assetCode: String) -> String {
        "flags/round/\(assetCode).svg#\(roundAssetVersion)"
    }

    /// Geneva, Vaud, Neuchâtel, and Jura are French-speaking and Ticino is Italian-speaking —
    /// SwissCantonRegistry carries their French/Italian dialect names, not German ones, so they
    /// are excluded here and handled separately as the "ch-french"/"ch-italian" entries below.
    private static let nonGermanCantonCodes: Set<String> = ["GE", "VD", "NE", "JU", "TI"]

    private static let swissGermanCantons: [SeedDialect] = SwissCantonRegistry.cantons
        .filter { !nonGermanCantonCodes.contains($0.code) }
        .map { canton in
            let native = canton.dialectName.components(separatedBy: "(").first!.trimmingCharacters(in: .whitespaces)
            return SeedDialect(
                seedKey: "ch-canton-\(canton.code.lowercased())",
                groupKey: "swiss-german",
                countryCode: "CH",
                flagEmoji: "🇨🇭",
                assetCode: "ch-\(canton.code.lowercased())",
                countryNameEnglish: "Switzerland",
                countryNameNative: "Schweiz / Suisse / Svizzera",
                dialectNameEnglish: "Swiss German (\(canton.name))",
                dialectNameNative: native,
                promptName: canton.dialectName,
                searchKeywords: [canton.name, canton.germanName, canton.code, "Switzerland", "Swiss German", "Schwizerdütsch"]
            )
        }

    static let seedData: [SeedDialect] = swissGermanCantons + [
    SeedDialect(seedKey: "ch-french", groupKey: "french", countryCode: "CH", flagEmoji: "🇨🇭", assetCode: "ch", countryNameEnglish: "Switzerland", countryNameNative: "Schweiz / Suisse / Svizzera", dialectNameEnglish: "Swiss French", dialectNameNative: "Français (Suisse romande)", promptName: "Français (Genève)", searchKeywords: ["Switzerland", "Geneva", "Vaud", "Romandie"]),
    SeedDialect(seedKey: "ch-french-vaud", groupKey: "french", countryCode: "CH", flagEmoji: "🇨🇭", assetCode: "ch", countryNameEnglish: "Switzerland", countryNameNative: "Schweiz / Suisse / Svizzera", dialectNameEnglish: "Swiss French (Vaud)", dialectNameNative: "Français Vaudois", promptName: "Français Vaudois (Vaud)", searchKeywords: ["Switzerland", "Vaud"]),
    SeedDialect(seedKey: "ch-italian", groupKey: "italian", countryCode: "CH", flagEmoji: "🇨🇭", assetCode: "ch", countryNameEnglish: "Switzerland", countryNameNative: "Schweiz / Suisse / Svizzera", dialectNameEnglish: "Swiss Italian", dialectNameNative: "Italiano Ticinese", promptName: "Italiano Ticinese (Tessin)", searchKeywords: ["Switzerland", "Ticino"]),
    SeedDialect(seedKey: "ch-romansh", groupKey: nil, countryCode: "CH", flagEmoji: "🇨🇭", assetCode: "ch-gr", countryNameEnglish: "Switzerland", countryNameNative: "Schweiz / Suisse / Svizzera", dialectNameEnglish: "Romansh", dialectNameNative: "Rumantsch", promptName: "Rumantsch (Svizra)", searchKeywords: ["Switzerland", "Graubünden", "Grisons", "4th national language"]),
    SeedDialect(seedKey: "de-standard", groupKey: "german", countryCode: "DE", flagEmoji: "🇩🇪", assetCode: "de", countryNameEnglish: "Germany", countryNameNative: "Deutschland", dialectNameEnglish: "Standard German", dialectNameNative: "Hochdeutsch", promptName: "Hochdeutsch (Deutschland)", searchKeywords: ["Germany", "Liechtenstein"]),
    SeedDialect(seedKey: "de-bavarian", groupKey: "german", countryCode: "DE", flagEmoji: "🇩🇪", assetCode: "de-bavaria", countryNameEnglish: "Germany", countryNameNative: "Deutschland", dialectNameEnglish: "Bavarian", dialectNameNative: "Bairisch", promptName: "Bairisch", searchKeywords: ["Bavaria", "Bayern", "Munich"]),
    SeedDialect(seedKey: "de-plattdeutsch", groupKey: "german", countryCode: "DE", flagEmoji: "🇩🇪", assetCode: "de", countryNameEnglish: "Germany", countryNameNative: "Deutschland", dialectNameEnglish: "Low German", dialectNameNative: "Plattdeutsch", promptName: "Plattdeutsch", searchKeywords: ["Northern Germany"]),
    SeedDialect(seedKey: "de-swabian", groupKey: "german", countryCode: "DE", flagEmoji: "🇩🇪", assetCode: "de-swabia", countryNameEnglish: "Germany", countryNameNative: "Deutschland", dialectNameEnglish: "Swabian", dialectNameNative: "Schwäbisch", promptName: "Schwäbisch", searchKeywords: ["Baden-Württemberg", "Stuttgart"]),
    SeedDialect(seedKey: "de-saxon", groupKey: "german", countryCode: "DE", flagEmoji: "🇩🇪", assetCode: "de-saxony", countryNameEnglish: "Germany", countryNameNative: "Deutschland", dialectNameEnglish: "Saxon", dialectNameNative: "Sächsisch", promptName: "Sächsisch", searchKeywords: ["Saxony", "Dresden", "Leipzig"]),
    SeedDialect(seedKey: "de-koelsch", groupKey: "german", countryCode: "DE", flagEmoji: "🇩🇪", assetCode: "de-cologne", countryNameEnglish: "Germany", countryNameNative: "Deutschland", dialectNameEnglish: "Ripuarian (Kölsch)", dialectNameNative: "Kölsch", promptName: "Kölsch", searchKeywords: ["Cologne", "Köln", "North Rhine-Westphalia", "NRW"]),
    SeedDialect(seedKey: "at-standard", groupKey: "german", countryCode: "AT", flagEmoji: "🇦🇹", assetCode: "at", countryNameEnglish: "Austria", countryNameNative: "Österreich", dialectNameEnglish: "Austrian Standard German", dialectNameNative: "Österreichisches Deutsch", promptName: "Österreichisches Deutsch", searchKeywords: ["Austria"]),
    SeedDialect(seedKey: "at-viennese", groupKey: "german", countryCode: "AT", flagEmoji: "🇦🇹", assetCode: "at", countryNameEnglish: "Austria", countryNameNative: "Österreich", dialectNameEnglish: "Viennese", dialectNameNative: "Wienerisch", promptName: "Wienerisch", searchKeywords: ["Vienna", "Wien"]),
    SeedDialect(seedKey: "at-tyrolean", groupKey: "german", countryCode: "AT", flagEmoji: "🇦🇹", assetCode: "at", countryNameEnglish: "Austria", countryNameNative: "Österreich", dialectNameEnglish: "Tyrolean", dialectNameNative: "Tirolerisch", promptName: "Tirolerisch", searchKeywords: ["Tyrol", "Tirol"]),
    SeedDialect(seedKey: "na-german", groupKey: "german", countryCode: "NA", flagEmoji: "🇳🇦", assetCode: "na", countryNameEnglish: "Namibia", countryNameNative: "Namibia", dialectNameEnglish: "Namibian German", dialectNameNative: "Namdeutsch", promptName: "Namdeutsch (Namibia)", searchKeywords: ["Namibia"]),
    SeedDialect(seedKey: "fr-standard", groupKey: "french", countryCode: "FR", flagEmoji: "🇫🇷", assetCode: "fr", countryNameEnglish: "France", countryNameNative: "France", dialectNameEnglish: "Standard French", dialectNameNative: "Français", promptName: "Français (France)", searchKeywords: ["France", "Monaco", "Belgium", "Senegal", "Ivory Coast", "Mali", "Gabon"]),
    SeedDialect(seedKey: "fr-breton", groupKey: "french", countryCode: "FR", flagEmoji: "🇫🇷", assetCode: "fr-bre", countryNameEnglish: "France", countryNameNative: "France", dialectNameEnglish: "Breton", dialectNameNative: "Brezhoneg", promptName: "Breton (Brezhoneg)", searchKeywords: ["Brittany", "Bretagne"]),
    SeedDialect(seedKey: "fr-occitan", groupKey: "french", countryCode: "FR", flagEmoji: "🇫🇷", assetCode: "fr", countryNameEnglish: "France", countryNameNative: "France", dialectNameEnglish: "Occitan", dialectNameNative: "Lenga d'òc", promptName: "Occitan (Lenga d'òc)", searchKeywords: ["Occitanie"]),
    SeedDialect(seedKey: "ca-quebec", groupKey: "french", countryCode: "CA", flagEmoji: "🇨🇦", assetCode: "ca", countryNameEnglish: "Canada", countryNameNative: "Canada", dialectNameEnglish: "Canadian French", dialectNameNative: "Français québécois", promptName: "Français québécois (Québec)", searchKeywords: ["Canada", "Quebec", "Québec"]),
    SeedDialect(seedKey: "ht-creole", groupKey: nil, countryCode: "HT", flagEmoji: "🇭🇹", assetCode: "ht", countryNameEnglish: "Haiti", countryNameNative: "Ayiti", dialectNameEnglish: "Haitian Creole", dialectNameNative: "Kreyòl Ayisyen", promptName: "Kreyòl Ayisyen (Haïti)", searchKeywords: ["Haiti"]),
    SeedDialect(seedKey: "it-standard", groupKey: "italian", countryCode: "IT", flagEmoji: "🇮🇹", assetCode: "it", countryNameEnglish: "Italy", countryNameNative: "Italia", dialectNameEnglish: "Standard Italian", dialectNameNative: "Italiano", promptName: "Italiano (Italia)", searchKeywords: ["Italy", "San Marino", "Vatican City"]),
    SeedDialect(seedKey: "it-sicilian", groupKey: "italian", countryCode: "IT", flagEmoji: "🇮🇹", assetCode: "it-sicily", countryNameEnglish: "Italy", countryNameNative: "Italia", dialectNameEnglish: "Sicilian", dialectNameNative: "Sicilianu", promptName: "Sicilianu (Sicilia)", searchKeywords: ["Sicily", "Sicilia"]),
    SeedDialect(seedKey: "it-neapolitan", groupKey: "italian", countryCode: "IT", flagEmoji: "🇮🇹", assetCode: "it", countryNameEnglish: "Italy", countryNameNative: "Italia", dialectNameEnglish: "Neapolitan", dialectNameNative: "Nnapulitano", promptName: "Nnapulitano (Napoli)", searchKeywords: ["Naples", "Napoli", "Campania"]),
    SeedDialect(seedKey: "es-standard", groupKey: "spanish", countryCode: "ES", flagEmoji: "🇪🇸", assetCode: "es", countryNameEnglish: "Spain", countryNameNative: "España", dialectNameEnglish: "Standard Spanish (Castilian)", dialectNameNative: "Español (Castellano)", promptName: "Español", searchKeywords: ["Spain", "Bolivia", "Colombia", "Costa Rica", "Cuba", "Dominican Republic", "Ecuador", "El Salvador", "Equatorial Guinea", "Guatemala", "Honduras", "Nicaragua", "Panama", "Paraguay", "Peru", "Uruguay", "Venezuela"]),
    SeedDialect(seedKey: "mx-spanish", groupKey: "spanish", countryCode: "MX", flagEmoji: "🇲🇽", assetCode: "mx", countryNameEnglish: "Mexico", countryNameNative: "México", dialectNameEnglish: "Mexican Spanish", dialectNameNative: "Español mexicano", promptName: "Español mexicano (México)", searchKeywords: ["Mexico"]),
    SeedDialect(seedKey: "ar-spanish", groupKey: "spanish", countryCode: "AR", flagEmoji: "🇦🇷", assetCode: "ar", countryNameEnglish: "Argentina", countryNameNative: "Argentina", dialectNameEnglish: "Argentine Spanish", dialectNameNative: "Español rioplatense", promptName: "Español rioplatense (Argentina)", searchKeywords: ["Argentina", "Rioplatense", "voseo"]),
    SeedDialect(seedKey: "cl-spanish", groupKey: "spanish", countryCode: "CL", flagEmoji: "🇨🇱", assetCode: "cl", countryNameEnglish: "Chile", countryNameNative: "Chile", dialectNameEnglish: "Chilean Spanish", dialectNameNative: "Español chileno", promptName: "Español chileno (Chile)", searchKeywords: ["Chile"]),
    SeedDialect(seedKey: "es-catalan", groupKey: nil, countryCode: "ES", flagEmoji: "🇪🇸", assetCode: "es-ct", countryNameEnglish: "Spain", countryNameNative: "España", dialectNameEnglish: "Catalan", dialectNameNative: "Català", promptName: "Català (Catalunya)", searchKeywords: ["Catalonia", "Catalunya", "Andorra"]),
    SeedDialect(seedKey: "es-galician", groupKey: nil, countryCode: "ES", flagEmoji: "🇪🇸", assetCode: "es-ga", countryNameEnglish: "Spain", countryNameNative: "España", dialectNameEnglish: "Galician", dialectNameNative: "Galego", promptName: "Galego (Galicia)", searchKeywords: ["Galicia"]),
    SeedDialect(seedKey: "es-basque", groupKey: "spanish", countryCode: "ES", flagEmoji: "🇪🇸", assetCode: "es-pv", countryNameEnglish: "Spain", countryNameNative: "España", dialectNameEnglish: "Basque", dialectNameNative: "Euskara", promptName: "Euskara (País Vasco)", searchKeywords: ["Basque Country", "Euskadi", "País Vasco"]),
    SeedDialect(seedKey: "gb-english", groupKey: "english", countryCode: "GB", flagEmoji: "🇬🇧", assetCode: "gb", countryNameEnglish: "United Kingdom", countryNameNative: "United Kingdom", dialectNameEnglish: "British English", dialectNameNative: "British English", promptName: "English (UK)", searchKeywords: ["United Kingdom", "Ireland", "Saint Lucia", "Jamaica", "Nigeria", "Ghana", "Zambia", "Gambia", "Sierra Leone", "Uganda", "South Sudan", "Namibia", "Trinidad and Tobago", "Barbados", "Bahamas", "Belize", "Grenada", "Dominica", "Saint Kitts and Nevis", "Antigua and Barbuda", "Guyana", "India", "Pakistan", "Malaysia", "Malta", "Cyprus", "Kenya", "Tanzania", "Botswana", "Lesotho", "Eswatini", "Malawi", "Fiji", "Kiribati", "Micronesia", "Nauru"]),
    SeedDialect(seedKey: "us-english", groupKey: "english", countryCode: "US", flagEmoji: "🇺🇸", assetCode: "us", countryNameEnglish: "United States", countryNameNative: "United States", dialectNameEnglish: "American English", dialectNameNative: "American English", promptName: "English (US)", searchKeywords: ["United States", "Philippines", "Liberia"]),
    SeedDialect(seedKey: "us-southern", groupKey: "english", countryCode: "US", flagEmoji: "🇺🇸", assetCode: "us", countryNameEnglish: "United States", countryNameNative: "United States", dialectNameEnglish: "Southern American English", dialectNameNative: "Southern US English", promptName: "Southern American English", searchKeywords: ["Southern United States"]),
    SeedDialect(seedKey: "au-english", groupKey: "english", countryCode: "AU", flagEmoji: "🇦🇺", assetCode: "au", countryNameEnglish: "Australia", countryNameNative: "Australia", dialectNameEnglish: "Australian English", dialectNameNative: "Australian English", promptName: "Australian English", searchKeywords: ["Australia"]),
    SeedDialect(seedKey: "nz-english", groupKey: "english", countryCode: "NZ", flagEmoji: "🇳🇿", assetCode: "nz", countryNameEnglish: "New Zealand", countryNameNative: "New Zealand", dialectNameEnglish: "New Zealand English", dialectNameNative: "New Zealand English", promptName: "New Zealand English", searchKeywords: ["New Zealand", "Aotearoa"]),
    SeedDialect(seedKey: "sg-singlish", groupKey: "english", countryCode: "SG", flagEmoji: "🇸🇬", assetCode: "sg", countryNameEnglish: "Singapore", countryNameNative: "Singapore", dialectNameEnglish: "Singlish", dialectNameNative: "Singlish", promptName: "Singlish (Singapore)", searchKeywords: ["Singapore"]),
    SeedDialect(seedKey: "gb-scottish-gaelic", groupKey: nil, countryCode: "GB", flagEmoji: "🇬🇧", assetCode: "gb-sct", countryNameEnglish: "United Kingdom", countryNameNative: "United Kingdom", dialectNameEnglish: "Scottish Gaelic", dialectNameNative: "Gàidhlig", promptName: "Scottish Gaelic", searchKeywords: ["Scotland"]),
    SeedDialect(seedKey: "gb-welsh", groupKey: nil, countryCode: "GB", flagEmoji: "🇬🇧", assetCode: "gb-wls", countryNameEnglish: "United Kingdom", countryNameNative: "United Kingdom", dialectNameEnglish: "Welsh", dialectNameNative: "Cymraeg", promptName: "Welsh (Cymraeg)", searchKeywords: ["Wales", "Cymru"]),
    SeedDialect(seedKey: "nz-maori", groupKey: nil, countryCode: "NZ", flagEmoji: "🇳🇿", assetCode: "nz", countryNameEnglish: "New Zealand", countryNameNative: "New Zealand", dialectNameEnglish: "Māori", dialectNameNative: "Te Reo Māori", promptName: "Te Reo Māori", searchKeywords: ["New Zealand", "Aotearoa"]),
    SeedDialect(seedKey: "jm-patois", groupKey: nil, countryCode: "JM", flagEmoji: "🇯🇲", assetCode: "jm", countryNameEnglish: "Jamaica", countryNameNative: "Jamaica", dialectNameEnglish: "Jamaican Patois", dialectNameNative: "Jamaican Patois", promptName: "Jamaican Patois", searchKeywords: ["Jamaica"]),
    SeedDialect(seedKey: "bz-kriol", groupKey: nil, countryCode: "BZ", flagEmoji: "🇧🇿", assetCode: "bz", countryNameEnglish: "Belize", countryNameNative: "Belize", dialectNameEnglish: "Belizean Kriol", dialectNameNative: "Belizean Kriol", promptName: "Belizean Kriol", searchKeywords: ["Belize"]),
    SeedDialect(seedKey: "gr-standard", groupKey: "greek", countryCode: "GR", flagEmoji: "🇬🇷", assetCode: "gr", countryNameEnglish: "Greece", countryNameNative: "Ελλάδα", dialectNameEnglish: "Standard Greek", dialectNameNative: "Ελληνικά", promptName: "Ελληνικά (Greece)", searchKeywords: ["Greece"]),
    SeedDialect(seedKey: "cy-greek", groupKey: "greek", countryCode: "CY", flagEmoji: "🇨🇾", assetCode: "cy", countryNameEnglish: "Cyprus", countryNameNative: "Κύπρος", dialectNameEnglish: "Cypriot Greek", dialectNameNative: "Κυπριακά Ελληνικά", promptName: "Κυπριακά Ελληνικά (Κύπρος)", searchKeywords: ["Cyprus"]),
    SeedDialect(seedKey: "ar-msa", groupKey: "arabic", countryCode: "SA", flagEmoji: "🇸🇦", assetCode: "sa", countryNameEnglish: "Saudi Arabia", countryNameNative: "السعودية", dialectNameEnglish: "Modern Standard Arabic", dialectNameNative: "العربية الفصحى", promptName: "العربية الفصحى", searchKeywords: ["Saudi Arabia", "United Arab Emirates", "Iraq", "Jordan", "Kuwait", "Qatar", "Bahrain", "Oman", "Yemen", "Syria", "Libya", "Mauritania", "Sudan", "Palestine"]),
    SeedDialect(seedKey: "ar-egyptian", groupKey: "arabic", countryCode: "EG", flagEmoji: "🇪🇬", assetCode: "eg", countryNameEnglish: "Egypt", countryNameNative: "مصر", dialectNameEnglish: "Egyptian Arabic", dialectNameNative: "العربية المصرية", promptName: "العربية المصرية (مصر)", searchKeywords: ["Egypt"]),
    SeedDialect(seedKey: "ar-levantine", groupKey: "arabic", countryCode: "LB", flagEmoji: "🇱🇧", assetCode: "lb", countryNameEnglish: "Lebanon", countryNameNative: "لبنان", dialectNameEnglish: "Levantine Arabic", dialectNameNative: "العربية الشامية", promptName: "العربية الشامية (بلاد الشام)", searchKeywords: ["Lebanon", "Syria", "Jordan", "Palestine"]),
    SeedDialect(seedKey: "ar-gulf", groupKey: "arabic", countryCode: "AE", flagEmoji: "🇦🇪", assetCode: "ae", countryNameEnglish: "United Arab Emirates", countryNameNative: "الإمارات", dialectNameEnglish: "Gulf Arabic", dialectNameNative: "العربية الخليجية", promptName: "العربية الخليجية (الخليج)", searchKeywords: ["United Arab Emirates", "Saudi Arabia", "Qatar", "Kuwait", "Bahrain", "Oman"]),
    SeedDialect(seedKey: "ar-maghrebi", groupKey: "arabic", countryCode: "MA", flagEmoji: "🇲🇦", assetCode: "ma", countryNameEnglish: "Morocco", countryNameNative: "المغرب", dialectNameEnglish: "Maghrebi Arabic", dialectNameNative: "العربية الدارجة", promptName: "الدارجة المغاربية (المغرب العربي)", searchKeywords: ["Morocco", "Algeria", "Tunisia", "Libya"]),
    SeedDialect(seedKey: "in-assamese", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Assamese", dialectNameNative: "অসমীয়া", promptName: "অসমীয়া (Assamese)", searchKeywords: ["Assam"]),
    SeedDialect(seedKey: "in-bodo", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Bodo", dialectNameNative: "बड़ो", promptName: "बड़ो (Bodo)", searchKeywords: ["Assam"]),
    SeedDialect(seedKey: "in-dogri", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Dogri", dialectNameNative: "डोगरी", promptName: "डोगरी (Dogri)", searchKeywords: ["Jammu"]),
    SeedDialect(seedKey: "in-gujarati", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Gujarati", dialectNameNative: "ગુજરાતી", promptName: "Gujarati (India)", searchKeywords: ["Gujarat"]),
    SeedDialect(seedKey: "in-hindi", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Hindi", dialectNameNative: "हिन्दी", promptName: "Hindi (India)", searchKeywords: []),
    SeedDialect(seedKey: "in-kannada", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Kannada", dialectNameNative: "ಕನ್ನಡ", promptName: "ಕನ್ನಡ (Kannada)", searchKeywords: ["Karnataka"]),
    SeedDialect(seedKey: "in-kashmiri", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Kashmiri", dialectNameNative: "کٲشُر", promptName: "کٲشُر (Kashmiri)", searchKeywords: ["Kashmir"]),
    SeedDialect(seedKey: "in-konkani", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Konkani", dialectNameNative: "कोंकणी", promptName: "कोंकणी (Konkani)", searchKeywords: ["Goa"]),
    SeedDialect(seedKey: "in-maithili", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Maithili", dialectNameNative: "मैथिली", promptName: "मैथिली (Maithili)", searchKeywords: ["Bihar"]),
    SeedDialect(seedKey: "in-malayalam", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Malayalam", dialectNameNative: "മലയാളം", promptName: "മലയാളം (Malayalam)", searchKeywords: ["Kerala"]),
    SeedDialect(seedKey: "in-manipuri", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Manipuri (Meitei)", dialectNameNative: "মৈতৈলোন্", promptName: "মৈতৈলোন্ (Manipuri)", searchKeywords: ["Manipur"]),
    SeedDialect(seedKey: "in-marathi", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Marathi", dialectNameNative: "मराठी", promptName: "Marathi (India)", searchKeywords: ["Maharashtra"]),
    SeedDialect(seedKey: "in-odia", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Odia", dialectNameNative: "ଓଡ଼ିଆ", promptName: "ଓଡ଼ିଆ (Odia)", searchKeywords: ["Odisha"]),
    SeedDialect(seedKey: "in-punjabi", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Punjabi", dialectNameNative: "ਪੰਜਾਬੀ", promptName: "ਪੰਜਾਬੀ (Punjabi)", searchKeywords: ["Punjab"]),
    SeedDialect(seedKey: "in-sanskrit", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Sanskrit", dialectNameNative: "संस्कृतम्", promptName: "संस्कृतम् (Sanskrit)", searchKeywords: []),
    SeedDialect(seedKey: "in-santali", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Santali", dialectNameNative: "ᱥᱟᱱᱛᱟᱲᱤ", promptName: "ᱥᱟᱱᱛᱟᱲᱤ (Santali)", searchKeywords: ["Jharkhand"]),
    SeedDialect(seedKey: "in-sindhi", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Sindhi", dialectNameNative: "سنڌي", promptName: "سنڌي (Sindhi)", searchKeywords: []),
    SeedDialect(seedKey: "in-tamil", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Tamil", dialectNameNative: "தமிழ்", promptName: "Tamil (India)", searchKeywords: ["Tamil Nadu"]),
    SeedDialect(seedKey: "in-telugu", groupKey: "indian-languages", countryCode: "IN", flagEmoji: "🇮🇳", assetCode: "in", countryNameEnglish: "India", countryNameNative: "भारत", dialectNameEnglish: "Telugu", dialectNameNative: "తెలుగు", promptName: "Telugu (India)", searchKeywords: ["Andhra Pradesh", "Telangana"]),
    SeedDialect(seedKey: "bd-bengali", groupKey: nil, countryCode: "BD", flagEmoji: "🇧🇩", assetCode: "bd", countryNameEnglish: "Bangladesh", countryNameNative: "বাংলাদেশ", dialectNameEnglish: "Bengali", dialectNameNative: "বাংলা", promptName: "বাংলা (Bangladesh)", searchKeywords: ["Bangladesh", "India", "West Bengal"]),
    SeedDialect(seedKey: "np-nepali", groupKey: nil, countryCode: "NP", flagEmoji: "🇳🇵", assetCode: "np", countryNameEnglish: "Nepal", countryNameNative: "नेपाल", dialectNameEnglish: "Nepali", dialectNameNative: "नेपाली", promptName: "नेपाली (Nepal)", searchKeywords: ["Nepal", "India"]),
    SeedDialect(seedKey: "pk-urdu", groupKey: nil, countryCode: "PK", flagEmoji: "🇵🇰", assetCode: "pk", countryNameEnglish: "Pakistan", countryNameNative: "پاکستان", dialectNameEnglish: "Urdu", dialectNameNative: "اردو", promptName: "اردو (Pakistan)", searchKeywords: ["Pakistan", "India"]),
    SeedDialect(seedKey: "za-zulu", groupKey: "south-african-languages", countryCode: "ZA", flagEmoji: "🇿🇦", assetCode: "za", countryNameEnglish: "South Africa", countryNameNative: "South Africa", dialectNameEnglish: "Zulu", dialectNameNative: "isiZulu", promptName: "isiZulu", searchKeywords: ["South Africa"]),
    SeedDialect(seedKey: "za-xhosa", groupKey: "south-african-languages", countryCode: "ZA", flagEmoji: "🇿🇦", assetCode: "za", countryNameEnglish: "South Africa", countryNameNative: "South Africa", dialectNameEnglish: "Xhosa", dialectNameNative: "isiXhosa", promptName: "isiXhosa", searchKeywords: ["South Africa"]),
    SeedDialect(seedKey: "za-afrikaans", groupKey: "south-african-languages", countryCode: "ZA", flagEmoji: "🇿🇦", assetCode: "za", countryNameEnglish: "South Africa", countryNameNative: "South Africa", dialectNameEnglish: "Afrikaans", dialectNameNative: "Afrikaans", promptName: "Afrikaans", searchKeywords: ["South Africa", "Namibia"]),
    SeedDialect(seedKey: "za-sesotho", groupKey: "south-african-languages", countryCode: "ZA", flagEmoji: "🇿🇦", assetCode: "za", countryNameEnglish: "South Africa", countryNameNative: "South Africa", dialectNameEnglish: "Sesotho", dialectNameNative: "Sesotho", promptName: "Sesotho", searchKeywords: ["South Africa", "Lesotho"]),
    SeedDialect(seedKey: "za-setswana", groupKey: "south-african-languages", countryCode: "ZA", flagEmoji: "🇿🇦", assetCode: "za", countryNameEnglish: "South Africa", countryNameNative: "South Africa", dialectNameEnglish: "Setswana", dialectNameNative: "Setswana", promptName: "Setswana", searchKeywords: ["South Africa", "Botswana"]),
    SeedDialect(seedKey: "za-sepedi", groupKey: "south-african-languages", countryCode: "ZA", flagEmoji: "🇿🇦", assetCode: "za", countryNameEnglish: "South Africa", countryNameNative: "South Africa", dialectNameEnglish: "Sepedi", dialectNameNative: "Sepedi", promptName: "Sepedi", searchKeywords: ["South Africa"]),
    SeedDialect(seedKey: "za-siswati", groupKey: "south-african-languages", countryCode: "ZA", flagEmoji: "🇿🇦", assetCode: "za", countryNameEnglish: "South Africa", countryNameNative: "South Africa", dialectNameEnglish: "Swati", dialectNameNative: "siSwati", promptName: "siSwati", searchKeywords: ["South Africa", "Eswatini"]),
    SeedDialect(seedKey: "za-tshivenda", groupKey: "south-african-languages", countryCode: "ZA", flagEmoji: "🇿🇦", assetCode: "za", countryNameEnglish: "South Africa", countryNameNative: "South Africa", dialectNameEnglish: "Venda", dialectNameNative: "Tshivenda", promptName: "Tshivenda", searchKeywords: ["South Africa"]),
    SeedDialect(seedKey: "za-xitsonga", groupKey: "south-african-languages", countryCode: "ZA", flagEmoji: "🇿🇦", assetCode: "za", countryNameEnglish: "South Africa", countryNameNative: "South Africa", dialectNameEnglish: "Tsonga", dialectNameNative: "Xitsonga", promptName: "Xitsonga", searchKeywords: ["South Africa"]),
    SeedDialect(seedKey: "za-ndebele", groupKey: "south-african-languages", countryCode: "ZA", flagEmoji: "🇿🇦", assetCode: "za", countryNameEnglish: "South Africa", countryNameNative: "South Africa", dialectNameEnglish: "Ndebele", dialectNameNative: "isiNdebele", promptName: "isiNdebele", searchKeywords: ["South Africa"]),
    SeedDialect(seedKey: "ng-hausa", groupKey: "nigerian-languages", countryCode: "NG", flagEmoji: "🇳🇬", assetCode: "ng", countryNameEnglish: "Nigeria", countryNameNative: "Nigeria", dialectNameEnglish: "Hausa", dialectNameNative: "Hausa", promptName: "Hausa (Nigeria)", searchKeywords: ["Nigeria"]),
    SeedDialect(seedKey: "ng-yoruba", groupKey: "nigerian-languages", countryCode: "NG", flagEmoji: "🇳🇬", assetCode: "ng", countryNameEnglish: "Nigeria", countryNameNative: "Nigeria", dialectNameEnglish: "Yoruba", dialectNameNative: "Yorùbá", promptName: "Yorùbá (Nigeria)", searchKeywords: ["Nigeria"]),
    SeedDialect(seedKey: "ng-igbo", groupKey: "nigerian-languages", countryCode: "NG", flagEmoji: "🇳🇬", assetCode: "ng", countryNameEnglish: "Nigeria", countryNameNative: "Nigeria", dialectNameEnglish: "Igbo", dialectNameNative: "Igbo", promptName: "Igbo (Nigeria)", searchKeywords: ["Nigeria"]),
    SeedDialect(seedKey: "cd-lingala", groupKey: "congolese-languages", countryCode: "CD", flagEmoji: "🇨🇩", assetCode: "cd", countryNameEnglish: "DR Congo", countryNameNative: "RD Congo", dialectNameEnglish: "Lingala", dialectNameNative: "Lingála", promptName: "Lingála (RD Congo)", searchKeywords: ["Democratic Republic of the Congo", "Republic of the Congo"]),
    SeedDialect(seedKey: "cd-kikongo", groupKey: "congolese-languages", countryCode: "CD", flagEmoji: "🇨🇩", assetCode: "cd", countryNameEnglish: "DR Congo", countryNameNative: "RD Congo", dialectNameEnglish: "Kikongo", dialectNameNative: "Kikongo", promptName: "Kikongo (RD Congo)", searchKeywords: ["Democratic Republic of the Congo"]),
    SeedDialect(seedKey: "cd-tshiluba", groupKey: "congolese-languages", countryCode: "CD", flagEmoji: "🇨🇩", assetCode: "cd", countryNameEnglish: "DR Congo", countryNameNative: "RD Congo", dialectNameEnglish: "Tshiluba", dialectNameNative: "Tshiluba", promptName: "Tshiluba (RD Congo)", searchKeywords: ["Democratic Republic of the Congo"]),
    SeedDialect(seedKey: "al-albanian", groupKey: nil, countryCode: "AL", flagEmoji: "🇦🇱", assetCode: "al", countryNameEnglish: "Albania", countryNameNative: "Shqipëri", dialectNameEnglish: "Albanian", dialectNameNative: "Shqip", promptName: "Shqip (Albania)", searchKeywords: ["Albania", "Kosovo"]),
    SeedDialect(seedKey: "by-belarusian", groupKey: nil, countryCode: "BY", flagEmoji: "🇧🇾", assetCode: "by", countryNameEnglish: "Belarus", countryNameNative: "Беларусь", dialectNameEnglish: "Belarusian", dialectNameNative: "Беларуская", promptName: "Беларуская (Belarus)", searchKeywords: ["Belarus"]),
    SeedDialect(seedKey: "ba-bosnian", groupKey: nil, countryCode: "BA", flagEmoji: "🇧🇦", assetCode: "ba", countryNameEnglish: "Bosnia and Herzegovina", countryNameNative: "Bosna i Hercegovina", dialectNameEnglish: "Bosnian", dialectNameNative: "Bosanski", promptName: "Bosanski (Bosnia)", searchKeywords: ["Bosnia and Herzegovina"]),
    SeedDialect(seedKey: "bg-bulgarian", groupKey: nil, countryCode: "BG", flagEmoji: "🇧🇬", assetCode: "bg", countryNameEnglish: "Bulgaria", countryNameNative: "България", dialectNameEnglish: "Bulgarian", dialectNameNative: "Български", promptName: "Български (Bulgaria)", searchKeywords: ["Bulgaria"]),
    SeedDialect(seedKey: "hr-croatian", groupKey: nil, countryCode: "HR", flagEmoji: "🇭🇷", assetCode: "hr", countryNameEnglish: "Croatia", countryNameNative: "Hrvatska", dialectNameEnglish: "Croatian", dialectNameNative: "Hrvatski", promptName: "Hrvatski (Croatia)", searchKeywords: ["Croatia"]),
    SeedDialect(seedKey: "cz-czech", groupKey: nil, countryCode: "CZ", flagEmoji: "🇨🇿", assetCode: "cz", countryNameEnglish: "Czechia", countryNameNative: "Česko", dialectNameEnglish: "Czech", dialectNameNative: "Čeština", promptName: "Čeština (Czechia)", searchKeywords: ["Czechia", "Czech Republic"]),
    SeedDialect(seedKey: "ee-estonian", groupKey: nil, countryCode: "EE", flagEmoji: "🇪🇪", assetCode: "ee", countryNameEnglish: "Estonia", countryNameNative: "Eesti", dialectNameEnglish: "Estonian", dialectNameNative: "Eesti keel", promptName: "Eesti keel (Estonia)", searchKeywords: ["Estonia"]),
    SeedDialect(seedKey: "hu-hungarian", groupKey: nil, countryCode: "HU", flagEmoji: "🇭🇺", assetCode: "hu", countryNameEnglish: "Hungary", countryNameNative: "Magyarország", dialectNameEnglish: "Hungarian", dialectNameNative: "Magyar", promptName: "Magyar (Hungary)", searchKeywords: ["Hungary"]),
    SeedDialect(seedKey: "is-icelandic", groupKey: nil, countryCode: "IS", flagEmoji: "🇮🇸", assetCode: "is", countryNameEnglish: "Iceland", countryNameNative: "Ísland", dialectNameEnglish: "Icelandic", dialectNameNative: "Íslenska", promptName: "Íslenska (Iceland)", searchKeywords: ["Iceland"]),
    SeedDialect(seedKey: "ie-irish", groupKey: nil, countryCode: "IE", flagEmoji: "🇮🇪", assetCode: "ie", countryNameEnglish: "Ireland", countryNameNative: "Éire", dialectNameEnglish: "Irish", dialectNameNative: "Gaeilge", promptName: "Gaeilge (Ireland)", searchKeywords: ["Ireland"]),
    SeedDialect(seedKey: "lv-latvian", groupKey: nil, countryCode: "LV", flagEmoji: "🇱🇻", assetCode: "lv", countryNameEnglish: "Latvia", countryNameNative: "Latvija", dialectNameEnglish: "Latvian", dialectNameNative: "Latviešu", promptName: "Latviešu (Latvia)", searchKeywords: ["Latvia"]),
    SeedDialect(seedKey: "lt-lithuanian", groupKey: nil, countryCode: "LT", flagEmoji: "🇱🇹", assetCode: "lt", countryNameEnglish: "Lithuania", countryNameNative: "Lietuva", dialectNameEnglish: "Lithuanian", dialectNameNative: "Lietuvių", promptName: "Lietuvių (Lithuania)", searchKeywords: ["Lithuania"]),
    SeedDialect(seedKey: "lu-luxembourgish", groupKey: nil, countryCode: "LU", flagEmoji: "🇱🇺", assetCode: "lu", countryNameEnglish: "Luxembourg", countryNameNative: "Lëtzebuerg", dialectNameEnglish: "Luxembourgish", dialectNameNative: "Lëtzebuergesch", promptName: "Lëtzebuergesch (Luxembourg)", searchKeywords: ["Luxembourg"]),
    SeedDialect(seedKey: "mt-maltese", groupKey: nil, countryCode: "MT", flagEmoji: "🇲🇹", assetCode: "mt", countryNameEnglish: "Malta", countryNameNative: "Malta", dialectNameEnglish: "Maltese", dialectNameNative: "Malti", promptName: "Malti (Malta)", searchKeywords: ["Malta"]),
    SeedDialect(seedKey: "me-montenegrin", groupKey: nil, countryCode: "ME", flagEmoji: "🇲🇪", assetCode: "me", countryNameEnglish: "Montenegro", countryNameNative: "Crna Gora", dialectNameEnglish: "Montenegrin", dialectNameNative: "Crnogorski", promptName: "Crnogorski (Montenegro)", searchKeywords: ["Montenegro"]),
    SeedDialect(seedKey: "nl-dutch", groupKey: nil, countryCode: "NL", flagEmoji: "🇳🇱", assetCode: "nl", countryNameEnglish: "Netherlands", countryNameNative: "Nederland", dialectNameEnglish: "Dutch", dialectNameNative: "Nederlands", promptName: "Nederlands", searchKeywords: ["Netherlands", "Suriname"]),
    SeedDialect(seedKey: "mk-macedonian", groupKey: nil, countryCode: "MK", flagEmoji: "🇲🇰", assetCode: "mk", countryNameEnglish: "North Macedonia", countryNameNative: "Северна Македонија", dialectNameEnglish: "Macedonian", dialectNameNative: "Македонски", promptName: "Македонски (North Macedonia)", searchKeywords: ["North Macedonia"]),
    SeedDialect(seedKey: "pt-portuguese", groupKey: nil, countryCode: "PT", flagEmoji: "🇵🇹", assetCode: "pt", countryNameEnglish: "Portugal", countryNameNative: "Portugal", dialectNameEnglish: "European Portuguese", dialectNameNative: "Português", promptName: "Português (Portugal)", searchKeywords: ["Portugal", "Angola", "Mozambique", "Guinea-Bissau", "Cabo Verde", "São Tomé and Príncipe"]),
    SeedDialect(seedKey: "ro-romanian", groupKey: nil, countryCode: "RO", flagEmoji: "🇷🇴", assetCode: "ro", countryNameEnglish: "Romania", countryNameNative: "România", dialectNameEnglish: "Romanian", dialectNameNative: "Română", promptName: "Română (Romania)", searchKeywords: ["Romania", "Moldova"]),
    SeedDialect(seedKey: "ru-russian", groupKey: nil, countryCode: "RU", flagEmoji: "🇷🇺", assetCode: "ru", countryNameEnglish: "Russia", countryNameNative: "Россия", dialectNameEnglish: "Russian", dialectNameNative: "Русский", promptName: "Русский (Russia)", searchKeywords: ["Russia"]),
    SeedDialect(seedKey: "rs-serbian", groupKey: nil, countryCode: "RS", flagEmoji: "🇷🇸", assetCode: "rs", countryNameEnglish: "Serbia", countryNameNative: "Србија", dialectNameEnglish: "Serbian", dialectNameNative: "Српски", promptName: "Српски (Serbia)", searchKeywords: ["Serbia"]),
    SeedDialect(seedKey: "sk-slovak", groupKey: nil, countryCode: "SK", flagEmoji: "🇸🇰", assetCode: "sk", countryNameEnglish: "Slovakia", countryNameNative: "Slovensko", dialectNameEnglish: "Slovak", dialectNameNative: "Slovenčina", promptName: "Slovenčina (Slovakia)", searchKeywords: ["Slovakia"]),
    SeedDialect(seedKey: "si-slovenian", groupKey: nil, countryCode: "SI", flagEmoji: "🇸🇮", assetCode: "si", countryNameEnglish: "Slovenia", countryNameNative: "Slovenija", dialectNameEnglish: "Slovenian", dialectNameNative: "Slovenščina", promptName: "Slovenščina (Slovenia)", searchKeywords: ["Slovenia"]),
    SeedDialect(seedKey: "ua-ukrainian", groupKey: nil, countryCode: "UA", flagEmoji: "🇺🇦", assetCode: "ua", countryNameEnglish: "Ukraine", countryNameNative: "Україна", dialectNameEnglish: "Ukrainian", dialectNameNative: "Українська", promptName: "Українська (Ukraine)", searchKeywords: ["Ukraine"]),
    SeedDialect(seedKey: "va-latin", groupKey: nil, countryCode: "VA", flagEmoji: "🇻🇦", assetCode: "va", countryNameEnglish: "Vatican City", countryNameNative: "Città del Vaticano", dialectNameEnglish: "Latin", dialectNameNative: "Latina", promptName: "Latina (Vaticanum)", searchKeywords: ["Vatican City", "Holy See"]),
    SeedDialect(seedKey: "am-armenian", groupKey: nil, countryCode: "AM", flagEmoji: "🇦🇲", assetCode: "am", countryNameEnglish: "Armenia", countryNameNative: "Հայաստան", dialectNameEnglish: "Armenian", dialectNameNative: "Հայերեն", promptName: "Հայերեն (Armenia)", searchKeywords: ["Armenia"]),
    SeedDialect(seedKey: "az-azerbaijani", groupKey: nil, countryCode: "AZ", flagEmoji: "🇦🇿", assetCode: "az", countryNameEnglish: "Azerbaijan", countryNameNative: "Azərbaycan", dialectNameEnglish: "Azerbaijani", dialectNameNative: "Azərbaycan dili", promptName: "Azərbaycan dili (Azerbaijan)", searchKeywords: ["Azerbaijan"]),
    SeedDialect(seedKey: "ge-georgian", groupKey: nil, countryCode: "GE", flagEmoji: "🇬🇪", assetCode: "ge", countryNameEnglish: "Georgia", countryNameNative: "საქართველო", dialectNameEnglish: "Georgian", dialectNameNative: "ქართული", promptName: "ქართული (Georgia)", searchKeywords: ["Georgia"]),
    SeedDialect(seedKey: "bt-dzongkha", groupKey: nil, countryCode: "BT", flagEmoji: "🇧🇹", assetCode: "bt", countryNameEnglish: "Bhutan", countryNameNative: "འབྲུག་ཡུལ", dialectNameEnglish: "Dzongkha", dialectNameNative: "རྫོང་ཁ", promptName: "རྫོང་ཁ (Bhutan)", searchKeywords: ["Bhutan"]),
    SeedDialect(seedKey: "kh-khmer", groupKey: nil, countryCode: "KH", flagEmoji: "🇰🇭", assetCode: "kh", countryNameEnglish: "Cambodia", countryNameNative: "កម្ពុជា", dialectNameEnglish: "Khmer", dialectNameNative: "ខ្មែរ", promptName: "ខ្មែរ (Cambodia)", searchKeywords: ["Cambodia"]),
    SeedDialect(seedKey: "cn-mandarin", groupKey: nil, countryCode: "CN", flagEmoji: "🇨🇳", assetCode: "cn", countryNameEnglish: "China", countryNameNative: "中国", dialectNameEnglish: "Mandarin Chinese", dialectNameNative: "中文 (普通话)", promptName: "中文 (Chinese)", searchKeywords: ["China", "Taiwan"]),
    SeedDialect(seedKey: "hk-cantonese", groupKey: nil, countryCode: "HK", flagEmoji: "🇭🇰", assetCode: "hk", countryNameEnglish: "Hong Kong", countryNameNative: "香港", dialectNameEnglish: "Cantonese", dialectNameNative: "粵語", promptName: "粵語 (Cantonese)", searchKeywords: ["Hong Kong", "Guangdong", "China"]),
    SeedDialect(seedKey: "id-indonesian", groupKey: nil, countryCode: "ID", flagEmoji: "🇮🇩", assetCode: "id", countryNameEnglish: "Indonesia", countryNameNative: "Indonesia", dialectNameEnglish: "Indonesian", dialectNameNative: "Bahasa Indonesia", promptName: "Bahasa Indonesia (Indonesia)", searchKeywords: ["Indonesia"]),
    SeedDialect(seedKey: "ir-persian", groupKey: nil, countryCode: "IR", flagEmoji: "🇮🇷", assetCode: "ir", countryNameEnglish: "Iran", countryNameNative: "ایران", dialectNameEnglish: "Persian (Farsi)", dialectNameNative: "فارسی", promptName: "فارسی (Iran)", searchKeywords: ["Iran", "Afghanistan"]),
    SeedDialect(seedKey: "il-hebrew", groupKey: nil, countryCode: "IL", flagEmoji: "🇮🇱", assetCode: "il", countryNameEnglish: "Israel", countryNameNative: "ישראל", dialectNameEnglish: "Hebrew", dialectNameNative: "עברית", promptName: "עברית (Israel)", searchKeywords: ["Israel"]),
    SeedDialect(seedKey: "jp-japanese", groupKey: nil, countryCode: "JP", flagEmoji: "🇯🇵", assetCode: "jp", countryNameEnglish: "Japan", countryNameNative: "日本", dialectNameEnglish: "Japanese", dialectNameNative: "日本語", promptName: "日本語 (Japanese)", searchKeywords: ["Japan"]),
    SeedDialect(seedKey: "kz-kazakh", groupKey: nil, countryCode: "KZ", flagEmoji: "🇰🇿", assetCode: "kz", countryNameEnglish: "Kazakhstan", countryNameNative: "Қазақстан", dialectNameEnglish: "Kazakh", dialectNameNative: "Қазақ тілі", promptName: "Қазақ тілі (Kazakhstan)", searchKeywords: ["Kazakhstan"]),
    SeedDialect(seedKey: "kg-kyrgyz", groupKey: nil, countryCode: "KG", flagEmoji: "🇰🇬", assetCode: "kg", countryNameEnglish: "Kyrgyzstan", countryNameNative: "Кыргызстан", dialectNameEnglish: "Kyrgyz", dialectNameNative: "Кыргызча", promptName: "Кыргызча (Kyrgyzstan)", searchKeywords: ["Kyrgyzstan"]),
    SeedDialect(seedKey: "la-lao", groupKey: nil, countryCode: "LA", flagEmoji: "🇱🇦", assetCode: "la", countryNameEnglish: "Laos", countryNameNative: "ລາວ", dialectNameEnglish: "Lao", dialectNameNative: "ລາວ", promptName: "ລາວ (Laos)", searchKeywords: ["Laos"]),
    SeedDialect(seedKey: "my-malay", groupKey: nil, countryCode: "MY", flagEmoji: "🇲🇾", assetCode: "my", countryNameEnglish: "Malaysia", countryNameNative: "Malaysia", dialectNameEnglish: "Malay", dialectNameNative: "Bahasa Melayu", promptName: "Bahasa Melayu (Malaysia)", searchKeywords: ["Malaysia", "Brunei"]),
    SeedDialect(seedKey: "mv-dhivehi", groupKey: nil, countryCode: "MV", flagEmoji: "🇲🇻", assetCode: "mv", countryNameEnglish: "Maldives", countryNameNative: "ދިވެހިރާއްޖެ", dialectNameEnglish: "Dhivehi", dialectNameNative: "ދިވެހި", promptName: "ދިވެހި (Maldives)", searchKeywords: ["Maldives"]),
    SeedDialect(seedKey: "mn-mongolian", groupKey: nil, countryCode: "MN", flagEmoji: "🇲🇳", assetCode: "mn", countryNameEnglish: "Mongolia", countryNameNative: "Монгол улс", dialectNameEnglish: "Mongolian", dialectNameNative: "Монгол", promptName: "Монгол (Mongolia)", searchKeywords: ["Mongolia"]),
    SeedDialect(seedKey: "mm-burmese", groupKey: nil, countryCode: "MM", flagEmoji: "🇲🇲", assetCode: "mm", countryNameEnglish: "Myanmar", countryNameNative: "မြန်မာ", dialectNameEnglish: "Burmese", dialectNameNative: "မြန်မာဘာသာ", promptName: "မြန်မာဘာသာ (Myanmar)", searchKeywords: ["Myanmar", "Burma"]),
    SeedDialect(seedKey: "kp-korean", groupKey: nil, countryCode: "KR", flagEmoji: "🇰🇷", assetCode: "kr", countryNameEnglish: "South Korea", countryNameNative: "대한민국", dialectNameEnglish: "Korean", dialectNameNative: "한국어", promptName: "한국어 (Korean)", searchKeywords: ["South Korea", "North Korea"]),
    SeedDialect(seedKey: "ph-filipino", groupKey: nil, countryCode: "PH", flagEmoji: "🇵🇭", assetCode: "ph", countryNameEnglish: "Philippines", countryNameNative: "Pilipinas", dialectNameEnglish: "Filipino", dialectNameNative: "Filipino", promptName: "Filipino (Philippines)", searchKeywords: ["Philippines"]),
    SeedDialect(seedKey: "lk-sinhala", groupKey: nil, countryCode: "LK", flagEmoji: "🇱🇰", assetCode: "lk", countryNameEnglish: "Sri Lanka", countryNameNative: "ශ්‍රී ලංකාව", dialectNameEnglish: "Sinhala", dialectNameNative: "සිංහල", promptName: "සිංහල (Sri Lanka)", searchKeywords: ["Sri Lanka"]),
    SeedDialect(seedKey: "tj-tajik", groupKey: nil, countryCode: "TJ", flagEmoji: "🇹🇯", assetCode: "tj", countryNameEnglish: "Tajikistan", countryNameNative: "Тоҷикистон", dialectNameEnglish: "Tajik", dialectNameNative: "Тоҷикӣ", promptName: "Тоҷикӣ (Tajikistan)", searchKeywords: ["Tajikistan"]),
    SeedDialect(seedKey: "th-thai", groupKey: nil, countryCode: "TH", flagEmoji: "🇹🇭", assetCode: "th", countryNameEnglish: "Thailand", countryNameNative: "ประเทศไทย", dialectNameEnglish: "Thai", dialectNameNative: "ไทย", promptName: "ไทย (Thailand)", searchKeywords: ["Thailand"]),
    SeedDialect(seedKey: "tl-tetum", groupKey: nil, countryCode: "TL", flagEmoji: "🇹🇱", assetCode: "tl", countryNameEnglish: "Timor-Leste", countryNameNative: "Timor-Leste", dialectNameEnglish: "Tetum", dialectNameNative: "Tetun", promptName: "Tetun (Timor-Leste)", searchKeywords: ["Timor-Leste", "East Timor"]),
    SeedDialect(seedKey: "tm-turkmen", groupKey: nil, countryCode: "TM", flagEmoji: "🇹🇲", assetCode: "tm", countryNameEnglish: "Turkmenistan", countryNameNative: "Türkmenistan", dialectNameEnglish: "Turkmen", dialectNameNative: "Türkmençe", promptName: "Türkmençe (Turkmenistan)", searchKeywords: ["Turkmenistan"]),
    SeedDialect(seedKey: "tr-turkish", groupKey: nil, countryCode: "TR", flagEmoji: "🇹🇷", assetCode: "tr", countryNameEnglish: "Turkey", countryNameNative: "Türkiye", dialectNameEnglish: "Turkish", dialectNameNative: "Türkçe", promptName: "Türkçe (Turkey)", searchKeywords: ["Turkey", "Türkiye"]),
    SeedDialect(seedKey: "uz-uzbek", groupKey: nil, countryCode: "UZ", flagEmoji: "🇺🇿", assetCode: "uz", countryNameEnglish: "Uzbekistan", countryNameNative: "Oʻzbekiston", dialectNameEnglish: "Uzbek", dialectNameNative: "Oʻzbek tili", promptName: "Oʻzbek tili (Uzbekistan)", searchKeywords: ["Uzbekistan"]),
    SeedDialect(seedKey: "vn-vietnamese", groupKey: nil, countryCode: "VN", flagEmoji: "🇻🇳", assetCode: "vn", countryNameEnglish: "Vietnam", countryNameNative: "Việt Nam", dialectNameEnglish: "Vietnamese", dialectNameNative: "Tiếng Việt", promptName: "Tiếng Việt (Vietnam)", searchKeywords: ["Vietnam"]),
    SeedDialect(seedKey: "km-comorian", groupKey: nil, countryCode: "KM", flagEmoji: "🇰🇲", assetCode: "km", countryNameEnglish: "Comoros", countryNameNative: "Komori", dialectNameEnglish: "Comorian", dialectNameNative: "Shikomori", promptName: "Shikomori (Comoros)", searchKeywords: ["Comoros"]),
    SeedDialect(seedKey: "er-tigrinya", groupKey: nil, countryCode: "ER", flagEmoji: "🇪🇷", assetCode: "er", countryNameEnglish: "Eritrea", countryNameNative: "ኤርትራ", dialectNameEnglish: "Tigrinya", dialectNameNative: "ትግርኛ", promptName: "ትግርኛ (Eritrea)", searchKeywords: ["Eritrea"]),
    SeedDialect(seedKey: "et-amharic", groupKey: nil, countryCode: "ET", flagEmoji: "🇪🇹", assetCode: "et", countryNameEnglish: "Ethiopia", countryNameNative: "ኢትዮጵያ", dialectNameEnglish: "Amharic", dialectNameNative: "አማርኛ", promptName: "አማርኛ (Ethiopia)", searchKeywords: ["Ethiopia"]),
    SeedDialect(seedKey: "mg-malagasy", groupKey: nil, countryCode: "MG", flagEmoji: "🇲🇬", assetCode: "mg", countryNameEnglish: "Madagascar", countryNameNative: "Madagasikara", dialectNameEnglish: "Malagasy", dialectNameNative: "Malagasy", promptName: "Malagasy (Madagascar)", searchKeywords: ["Madagascar"]),
    SeedDialect(seedKey: "rw-kinyarwanda", groupKey: nil, countryCode: "RW", flagEmoji: "🇷🇼", assetCode: "rw", countryNameEnglish: "Rwanda", countryNameNative: "Rwanda", dialectNameEnglish: "Kinyarwanda", dialectNameNative: "Ikinyarwanda", promptName: "Ikinyarwanda (Rwanda)", searchKeywords: ["Rwanda"]),
    SeedDialect(seedKey: "bi-kirundi", groupKey: nil, countryCode: "BI", flagEmoji: "🇧🇮", assetCode: "bi", countryNameEnglish: "Burundi", countryNameNative: "Burundi", dialectNameEnglish: "Kirundi", dialectNameNative: "Ikirundi", promptName: "Ikirundi (Burundi)", searchKeywords: ["Burundi"]),
    SeedDialect(seedKey: "so-somali", groupKey: nil, countryCode: "SO", flagEmoji: "🇸🇴", assetCode: "so", countryNameEnglish: "Somalia", countryNameNative: "Soomaaliya", dialectNameEnglish: "Somali", dialectNameNative: "Soomaali", promptName: "Soomaali (Somalia)", searchKeywords: ["Somalia"]),
    SeedDialect(seedKey: "mw-chichewa", groupKey: nil, countryCode: "MW", flagEmoji: "🇲🇼", assetCode: "mw", countryNameEnglish: "Malawi", countryNameNative: "Malawi", dialectNameEnglish: "Chichewa", dialectNameNative: "Chichewa", promptName: "Chichewa (Malawi)", searchKeywords: ["Malawi", "Nyanja"]),
    SeedDialect(seedKey: "gh-twi", groupKey: nil, countryCode: "GH", flagEmoji: "🇬🇭", assetCode: "gh", countryNameEnglish: "Ghana", countryNameNative: "Ghana", dialectNameEnglish: "Twi (Akan)", dialectNameNative: "Twi", promptName: "Twi (Ghana)", searchKeywords: ["Ghana", "Akan"]),
    SeedDialect(seedKey: "sn-wolof", groupKey: nil, countryCode: "SN", flagEmoji: "🇸🇳", assetCode: "sn", countryNameEnglish: "Senegal", countryNameNative: "Sénégal", dialectNameEnglish: "Wolof", dialectNameNative: "Wolof", promptName: "Wolof (Senegal)", searchKeywords: ["Senegal"]),
    SeedDialect(seedKey: "cf-sango", groupKey: nil, countryCode: "CF", flagEmoji: "🇨🇫", assetCode: "cf", countryNameEnglish: "Central African Republic", countryNameNative: "Centrafrique", dialectNameEnglish: "Sango", dialectNameNative: "Sango", promptName: "Sango (Central African Republic)", searchKeywords: ["Central African Republic"]),
    SeedDialect(seedKey: "cv-kriolu", groupKey: nil, countryCode: "CV", flagEmoji: "🇨🇻", assetCode: "cv", countryNameEnglish: "Cabo Verde", countryNameNative: "Cabo Verde", dialectNameEnglish: "Cape Verdean Creole", dialectNameNative: "Kriolu", promptName: "Kriolu (Cabo Verde)", searchKeywords: ["Cabo Verde", "Cape Verde"]),
    SeedDialect(seedKey: "sc-kreol", groupKey: nil, countryCode: "SC", flagEmoji: "🇸🇨", assetCode: "sc", countryNameEnglish: "Seychelles", countryNameNative: "Seychelles", dialectNameEnglish: "Seychellois Creole", dialectNameNative: "Kreol Seselwa", promptName: "Kreol Seselwa (Seychelles)", searchKeywords: ["Seychelles"]),
    SeedDialect(seedKey: "mu-kreol", groupKey: nil, countryCode: "MU", flagEmoji: "🇲🇺", assetCode: "mu", countryNameEnglish: "Mauritius", countryNameNative: "Maurice", dialectNameEnglish: "Mauritian Creole", dialectNameNative: "Kreol Morisien", promptName: "Kreol Morisien (Mauritius)", searchKeywords: ["Mauritius"]),
    SeedDialect(seedKey: "pg-tokpisin", groupKey: nil, countryCode: "PG", flagEmoji: "🇵🇬", assetCode: "pg", countryNameEnglish: "Papua New Guinea", countryNameNative: "Papua New Guinea", dialectNameEnglish: "Tok Pisin", dialectNameNative: "Tok Pisin", promptName: "Tok Pisin (Papua New Guinea)", searchKeywords: ["Papua New Guinea"]),
    SeedDialect(seedKey: "vu-bislama", groupKey: nil, countryCode: "VU", flagEmoji: "🇻🇺", assetCode: "vu", countryNameEnglish: "Vanuatu", countryNameNative: "Vanuatu", dialectNameEnglish: "Bislama", dialectNameNative: "Bislama", promptName: "Bislama (Vanuatu)", searchKeywords: ["Vanuatu"]),
    SeedDialect(seedKey: "br-portuguese", groupKey: nil, countryCode: "BR", flagEmoji: "🇧🇷", assetCode: "br", countryNameEnglish: "Brazil", countryNameNative: "Brasil", dialectNameEnglish: "Brazilian Portuguese", dialectNameNative: "Português", promptName: "Português (Brasil)", searchKeywords: ["Brazil"]),
    SeedDialect(seedKey: "py-guarani", groupKey: nil, countryCode: "PY", flagEmoji: "🇵🇾", assetCode: "py", countryNameEnglish: "Paraguay", countryNameNative: "Paraguay", dialectNameEnglish: "Guaraní", dialectNameNative: "Guaraní", promptName: "Guaraní (Paraguay)", searchKeywords: ["Paraguay"]),
    SeedDialect(seedKey: "sr-sranan", groupKey: nil, countryCode: "SR", flagEmoji: "🇸🇷", assetCode: "sr", countryNameEnglish: "Suriname", countryNameNative: "Suriname", dialectNameEnglish: "Sranan Tongo", dialectNameNative: "Sranan Tongo", promptName: "Sranan Tongo (Suriname)", searchKeywords: ["Suriname"]),
    SeedDialect(seedKey: "fj-fijian", groupKey: nil, countryCode: "FJ", flagEmoji: "🇫🇯", assetCode: "fj", countryNameEnglish: "Fiji", countryNameNative: "Fiji", dialectNameEnglish: "Fijian", dialectNameNative: "Vosa Vakaviti", promptName: "Vosa Vakaviti (Fiji)", searchKeywords: ["Fiji"]),
    SeedDialect(seedKey: "ws-samoan", groupKey: nil, countryCode: "WS", flagEmoji: "🇼🇸", assetCode: "ws", countryNameEnglish: "Samoa", countryNameNative: "Samoa", dialectNameEnglish: "Samoan", dialectNameNative: "Gagana Sāmoa", promptName: "Gagana Sāmoa (Samoa)", searchKeywords: ["Samoa"]),
    SeedDialect(seedKey: "to-tongan", groupKey: nil, countryCode: "TO", flagEmoji: "🇹🇴", assetCode: "to", countryNameEnglish: "Tonga", countryNameNative: "Tonga", dialectNameEnglish: "Tongan", dialectNameNative: "Lea Faka-Tonga", promptName: "Lea Faka-Tonga (Tonga)", searchKeywords: ["Tonga"]),
    SeedDialect(seedKey: "tv-tuvaluan", groupKey: nil, countryCode: "TV", flagEmoji: "🇹🇻", assetCode: "tv", countryNameEnglish: "Tuvalu", countryNameNative: "Tuvalu", dialectNameEnglish: "Tuvaluan", dialectNameNative: "Te Ggana Tuuvalu", promptName: "Te Ggana Tuuvalu (Tuvalu)", searchKeywords: ["Tuvalu"]),
    SeedDialect(seedKey: "mh-marshallese", groupKey: nil, countryCode: "MH", flagEmoji: "🇲🇭", assetCode: "mh", countryNameEnglish: "Marshall Islands", countryNameNative: "Marshall Islands", dialectNameEnglish: "Marshallese", dialectNameNative: "Kajin M̧ajeļ", promptName: "Kajin M̧ajeļ (Marshall Islands)", searchKeywords: ["Marshall Islands"]),
    SeedDialect(seedKey: "pw-palauan", groupKey: nil, countryCode: "PW", flagEmoji: "🇵🇼", assetCode: "pw", countryNameEnglish: "Palau", countryNameNative: "Palau", dialectNameEnglish: "Palauan", dialectNameNative: "Tekoi ra Belau", promptName: "Tekoi ra Belau (Palau)", searchKeywords: ["Palau"]),
    SeedDialect(seedKey: "nr-nauruan", groupKey: nil, countryCode: "NR", flagEmoji: "🇳🇷", assetCode: "nr", countryNameEnglish: "Nauru", countryNameNative: "Nauru", dialectNameEnglish: "Nauruan", dialectNameNative: "Dorerin Naoero", promptName: "Dorerin Naoero (Nauru)", searchKeywords: ["Nauru"]),
    SeedDialect(seedKey: "ki-gilbertese", groupKey: nil, countryCode: "KI", flagEmoji: "🇰🇮", assetCode: "ki", countryNameEnglish: "Kiribati", countryNameNative: "Kiribati", dialectNameEnglish: "Gilbertese", dialectNameNative: "Te Taetae ni Kiribati", promptName: "Te Taetae ni Kiribati (Kiribati)", searchKeywords: ["Kiribati"]),
    SeedDialect(seedKey: "sb-pijin", groupKey: nil, countryCode: "SB", flagEmoji: "🇸🇧", assetCode: "sb", countryNameEnglish: "Solomon Islands", countryNameNative: "Solomon Islands", dialectNameEnglish: "Solomon Islands Pijin", dialectNameNative: "Pijin", promptName: "Pijin (Solomon Islands)", searchKeywords: ["Solomon Islands"]),
    ]

    private static let seedByKey: [String: SeedDialect] = Dictionary(uniqueKeysWithValues: seedData.map { ($0.seedKey, $0) })
    private static let seedByPromptName: [String: SeedDialect] = Dictionary(uniqueKeysWithValues: seedData.map { ($0.promptName, $0) })

    /// Fills in missing metadata and adds new seeding rows.
    ///
    /// Protection rule:
    ///  - isCustom == true                     -> never touched.
    ///  - isCustom == false && !isUserModified  -> safe to refresh from seedData.
    ///  - isCustom == false && isUserModified   -> pinned, never touched again.
    static func seedAndMigrate(context: ModelContext) throws {
        let existing = try context.fetch(FetchDescriptor<LanguageDialect>())
        for row in existing {
            applyRefreshIfNeeded(to: row)
        }
        let existingSeedKeys = Set(existing.compactMap { $0.seedKey })
        let existingNames = Set(existing.map { $0.name })
        let firstNewOrderIndex = (existing.map { $0.orderIndex }.max() ?? 0) + 1

        let missing = seedData.filter { !existingSeedKeys.contains($0.seedKey) && !existingNames.contains($0.promptName) }
        for (offset, seed) in missing.enumerated() {
            context.insert(newRow(for: seed, orderIndex: firstNewOrderIndex + offset))
        }
    }

    /// Refreshes a single row in place from seedData when it is unprotected and out of date.
    private static func applyRefreshIfNeeded(to row: LanguageDialect) {
        if row.isCustom || row.isUserModified { return }
        guard let seed = row.seedKey.flatMap({ seedByKey[$0] }) ?? seedByPromptName[row.name] else {
            backfillLegacyRowIfNeeded(row)
            return
        }
        guard differsFromSeed(row, seed) else { return }
        applySeed(seed, to: row)
    }

    private static func differsFromSeed(_ row: LanguageDialect, _ seed: SeedDialect) -> Bool {
        row.seedKey != seed.seedKey ||
        row.languageNameEnglish != seed.dialectNameEnglish ||
        row.languageNameNative != seed.dialectNameNative ||
        row.countryNameEnglish != seed.countryNameEnglish ||
        row.countryNameNative != seed.countryNameNative ||
        row.groupKey != seed.groupKey ||
        row.searchKeywords != seed.searchKeywords.joined(separator: ",") ||
        row.flatAssetUri != flatAssetUri(forAssetCode: seed.assetCode) ||
        row.customIconUrl != roundAssetUri(forAssetCode: seed.assetCode)
    }

    private static func applySeed(_ seed: SeedDialect, to row: LanguageDialect) {
        row.seedKey = seed.seedKey
        row.languageNameEnglish = seed.dialectNameEnglish
        row.languageNameNative = seed.dialectNameNative
        row.countryNameEnglish = seed.countryNameEnglish
        row.countryNameNative = seed.countryNameNative
        row.groupKey = seed.groupKey
        row.searchKeywords = seed.searchKeywords.joined(separator: ",")
        row.flatAssetUri = flatAssetUri(forAssetCode: seed.assetCode)
        row.customIconUrl = roundAssetUri(forAssetCode: seed.assetCode)
        // The asset changed shape - drop any stale cached bubble bitmap so it re-caches.
        row.localImagePath = nil
    }

    /// Fallback for rows with no matching seed entry at all (shouldn't normally happen).
    private static func backfillLegacyRowIfNeeded(_ row: LanguageDialect) {
        guard row.languageNameEnglish.isEmpty else { return }
        if row.countryCode == "CH" {
            let native = row.name.components(separatedBy: "(").first!.trimmingCharacters(in: .whitespaces)
            row.languageNameEnglish = "Swiss German (\(native))"
            row.languageNameNative = native
            row.countryNameEnglish = "Switzerland"
            row.countryNameNative = "Schweiz / Suisse"
        } else {
            row.languageNameEnglish = row.name
            row.languageNameNative = row.name
            row.countryNameEnglish = row.countryCode
            row.countryNameNative = row.countryCode
        }
    }

    private static func newRow(for seed: SeedDialect, orderIndex: Int) -> LanguageDialect {
        LanguageDialect(
            name: seed.promptName,
            countryCode: seed.countryCode,
            flagEmoji: seed.flagEmoji,
            customIconUrl: roundAssetUri(forAssetCode: seed.assetCode),
            isCustom: false,
            orderIndex: orderIndex,
            languageNameEnglish: seed.dialectNameEnglish,
            languageNameNative: seed.dialectNameNative,
            countryNameEnglish: seed.countryNameEnglish,
            countryNameNative: seed.countryNameNative,
            seedKey: seed.seedKey,
            searchKeywords: seed.searchKeywords.joined(separator: ","),
            groupKey: seed.groupKey,
            flatAssetUri: flatAssetUri(forAssetCode: seed.assetCode)
        )
    }
}
