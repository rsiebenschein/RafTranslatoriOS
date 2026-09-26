import Foundation

/// One row shown in the language picker sheet: either a standalone dialect, or a named group
/// (German, Swiss German, ...) with its member dialects collapsed underneath.
enum LanguagePickerRow: Identifiable {
    case single(LanguageDialect)
    case group(LanguageGroupInfo, [LanguageDialect])

    var id: String {
        switch self {
        case .single(let dialect): return "single-\(dialect.name)"
        case .group(let info, _): return "group-\(info.key)"
        }
    }

    var sortLabel: String {
        switch self {
        case .single(let dialect): return dialect.name
        case .group(let info, _): return info.labelEnglish
        }
    }
}

extension LanguageDialect {
    /// Matches the Android picker's search: name, either gloss, country, or comma-separated
    /// keywords, all case-insensitive.
    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let haystacks = [name, languageNameEnglish, languageNameNative, countryNameEnglish, countryNameNative, countryCode]
        if haystacks.contains(where: { $0.localizedCaseInsensitiveContains(query) }) {
            return true
        }
        return searchKeywords.split(separator: ",").contains {
            $0.trimmingCharacters(in: .whitespaces).localizedCaseInsensitiveContains(query)
        }
    }
}

enum LanguagePickerRowBuilder {
    /// Groups languages by `groupKey`, pins Swiss German first, then sorts everything else
    /// alphabetically — mirroring the Android app's language-first picker ordering.
    static func rows(from allLanguages: [LanguageDialect]) -> [LanguagePickerRow] {
        let (grouped, standalone) = (
            allLanguages.filter { !($0.groupKey ?? "").isEmpty },
            allLanguages.filter { ($0.groupKey ?? "").isEmpty }
        )
        let groupRows: [LanguagePickerRow] = Dictionary(grouping: grouped, by: { $0.groupKey ?? "" })
            .compactMap { key, children in
                LanguageGroups.info(forKey: key).map { .group($0, children.sorted { $0.name < $1.name }) }
            }
        let standaloneRows = standalone.map { LanguagePickerRow.single($0) }

        return (groupRows + standaloneRows).sorted { lhs, rhs in
            if case .group(let info, _) = lhs, info.key == "swiss-german" { return true }
            if case .group(let info, _) = rhs, info.key == "swiss-german" { return false }
            return lhs.sortLabel.localizedCaseInsensitiveCompare(rhs.sortLabel) == .orderedAscending
        }
    }

    /// Filters rows by search text: a standalone row matches directly; a group matches if any of
    /// its children do, keeping only the matching children.
    static func filter(_ rows: [LanguagePickerRow], query: String) -> [LanguagePickerRow] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return rows }
        return rows.compactMap { row in
            switch row {
            case .single(let dialect):
                return dialect.matches(query: trimmed) ? row : nil
            case .group(let info, let children):
                let matchingChildren = children.filter { $0.matches(query: trimmed) }
                return matchingChildren.isEmpty ? nil : .group(info, matchingChildren)
            }
        }
    }
}
