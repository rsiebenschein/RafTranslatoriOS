import Foundation

/// Registry of all 26 Swiss cantons: two-letter ISO code, English/German canton
/// name, and the default dialect name associated with the canton.
struct SwissCantonInfo {
    let code: String
    let name: String
    let germanName: String
    let dialectName: String
    let flagSvgUrl: String
}

enum SwissCantonRegistry {
    private static let baseGithubCantonRaw =
        "https://raw.githubusercontent.com/ylerjen/swiss-flags/master/cantons"

    static let cantons: [SwissCantonInfo] = [
        SwissCantonInfo(code: "AG", name: "Aargau", germanName: "Aargau", dialectName: "Aargauerdütsch (Aargau)", flagSvgUrl: "\(baseGithubCantonRaw)/ag.svg"),
        SwissCantonInfo(code: "AI", name: "Appenzell Innerrhoden", germanName: "Appenzell Innerrhoden", dialectName: "Appezellerisch (Innerrhode)", flagSvgUrl: "\(baseGithubCantonRaw)/ai.svg"),
        SwissCantonInfo(code: "AR", name: "Appenzell Ausserrhoden", germanName: "Appenzell Ausserrhoden", dialectName: "Appezellerisch (Usserrhode)", flagSvgUrl: "\(baseGithubCantonRaw)/ar.svg"),
        SwissCantonInfo(code: "BE", name: "Bern", germanName: "Bern", dialectName: "Bärndütsch (Berner Dialekt)", flagSvgUrl: "\(baseGithubCantonRaw)/be.svg"),
        SwissCantonInfo(code: "BL", name: "Basel-Landschaft", germanName: "Basel-Landschaft", dialectName: "Baselbieterdütsch (Baselland)", flagSvgUrl: "\(baseGithubCantonRaw)/bl.svg"),
        SwissCantonInfo(code: "BS", name: "Basel-Stadt", germanName: "Basel-Stadt", dialectName: "Baslerdüütsch (Basel-Stadt)", flagSvgUrl: "\(baseGithubCantonRaw)/bs.svg"),
        SwissCantonInfo(code: "FR", name: "Fribourg / Freiburg", germanName: "Freiburg", dialectName: "Senslerdütsch (Fribourg)", flagSvgUrl: "\(baseGithubCantonRaw)/fr.svg"),
        SwissCantonInfo(code: "GE", name: "Geneva / Genève", germanName: "Genf", dialectName: "Français (Genève)", flagSvgUrl: "\(baseGithubCantonRaw)/ge.svg"),
        SwissCantonInfo(code: "GL", name: "Glarus", germanName: "Glarus", dialectName: "Glarnerdütsch (Glarus)", flagSvgUrl: "\(baseGithubCantonRaw)/gl.svg"),
        SwissCantonInfo(code: "GR", name: "Graubünden / Grischun", germanName: "Graubünden", dialectName: "Bündnerdütsch (Graubünden)", flagSvgUrl: "\(baseGithubCantonRaw)/gr.svg"),
        SwissCantonInfo(code: "JU", name: "Jura", germanName: "Jura", dialectName: "Français (Jura)", flagSvgUrl: "\(baseGithubCantonRaw)/ju.svg"),
        SwissCantonInfo(code: "LU", name: "Lucerne / Luzern", germanName: "Luzern", dialectName: "Luzernerdütsch (Luzern)", flagSvgUrl: "\(baseGithubCantonRaw)/lu.svg"),
        SwissCantonInfo(code: "NE", name: "Neuchâtel", germanName: "Neuenburg", dialectName: "Français (Neuchâtel)", flagSvgUrl: "\(baseGithubCantonRaw)/ne.svg"),
        SwissCantonInfo(code: "NW", name: "Nidwalden", germanName: "Nidwalden", dialectName: "Nidwaldnerdütsch (Nidwalden)", flagSvgUrl: "\(baseGithubCantonRaw)/nw.svg"),
        SwissCantonInfo(code: "OW", name: "Obwalden", germanName: "Obwalden", dialectName: "Obwaldnerdütsch (Obwalden)", flagSvgUrl: "\(baseGithubCantonRaw)/ow.svg"),
        SwissCantonInfo(code: "SG", name: "St. Gallen", germanName: "St. Gallen", dialectName: "St. Galler Dialäkt (St. Gallen)", flagSvgUrl: "\(baseGithubCantonRaw)/sg.svg"),
        SwissCantonInfo(code: "SH", name: "Schaffhausen", germanName: "Schaffhausen", dialectName: "Schaffhuuserdütsch (Schaffhausen)", flagSvgUrl: "\(baseGithubCantonRaw)/sh.svg"),
        SwissCantonInfo(code: "SO", name: "Solothurn", germanName: "Solothurn", dialectName: "Soledurnerisch (Solothurn)", flagSvgUrl: "\(baseGithubCantonRaw)/so.svg"),
        SwissCantonInfo(code: "SZ", name: "Schwyz", germanName: "Schwyz", dialectName: "Schwyzerdütsch (Innerschwyz)", flagSvgUrl: "\(baseGithubCantonRaw)/sz.svg"),
        SwissCantonInfo(code: "TG", name: "Thurgau", germanName: "Thurgau", dialectName: "Thurgauerdütsch (Thurgau)", flagSvgUrl: "\(baseGithubCantonRaw)/tg.svg"),
        SwissCantonInfo(code: "TI", name: "Ticino / Tessin", germanName: "Tessin", dialectName: "Italiano Ticinese (Tessin)", flagSvgUrl: "\(baseGithubCantonRaw)/ti.svg"),
        SwissCantonInfo(code: "UR", name: "Uri", germanName: "Uri", dialectName: "Urnerdütsch (Uri)", flagSvgUrl: "\(baseGithubCantonRaw)/ur.svg"),
        SwissCantonInfo(code: "VD", name: "Vaud / Waadt", germanName: "Waadt", dialectName: "Français Vaudois (Vaud)", flagSvgUrl: "\(baseGithubCantonRaw)/vd.svg"),
        SwissCantonInfo(code: "VS", name: "Valais / Wallis", germanName: "Wallis", dialectName: "Walliserditsch (Wallis)", flagSvgUrl: "\(baseGithubCantonRaw)/vs.svg"),
        SwissCantonInfo(code: "ZG", name: "Zug", germanName: "Zug", dialectName: "Zugerdütsch (Zug)", flagSvgUrl: "\(baseGithubCantonRaw)/zg.svg"),
        SwissCantonInfo(code: "ZH", name: "Zürich", germanName: "Zürich", dialectName: "Schwizerdütsch - Zürcher Dialekt", flagSvgUrl: "\(baseGithubCantonRaw)/zh.svg"),
    ]

    static func findByCode(_ code: String) -> SwissCantonInfo? {
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        return cantons.first { $0.code.caseInsensitiveCompare(trimmed) == .orderedSame }
    }

    static func findByName(_ name: String) -> SwissCantonInfo? {
        cantons.first {
            $0.name.range(of: name, options: .caseInsensitive) != nil ||
            $0.germanName.range(of: name, options: .caseInsensitive) != nil ||
            name.range(of: $0.code, options: .caseInsensitive) != nil
        }
    }

    /// Constructs the flagcdn SVG URL for international countries, e.g. "in" -> "https://flagcdn.com/in.svg".
    static func countryFlagSvgUrl(countryCode: String) -> String {
        let code = countryCode.lowercased().trimmingCharacters(in: .whitespaces)
        return "https://flagcdn.com/\(code).svg"
    }
}
