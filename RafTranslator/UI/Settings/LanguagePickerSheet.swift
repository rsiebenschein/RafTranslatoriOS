import SwiftUI
import SwiftData

/// Full-screen searchable sheet for selecting, editing, or deleting a language/dialect.
struct LanguagePickerSheet: View {
    let allLanguages: [LanguageDialect]
    let selectedName: String
    let viewModel: SettingsViewModel
    let onSelect: (LanguageDialect) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""

    private var visibleRows: [LanguagePickerRow] {
        LanguagePickerRowBuilder.filter(LanguagePickerRowBuilder.rows(from: allLanguages), query: searchQuery)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(visibleRows) { row in
                    rowContent(row)
                }
            }
            .searchable(text: $searchQuery, prompt: "Search canton, country, or language")
            .navigationTitle("Select Language")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func rowContent(_ row: LanguagePickerRow) -> some View {
        switch row {
        case .single(let dialect):
            languageRow(dialect)
        case .group(let info, let children):
            Section(info.labelEnglish) {
                ForEach(children, id: \.name) { languageRow($0) }
            }
        }
    }

    private func languageRow(_ dialect: LanguageDialect) -> some View {
        LanguagePickerListRow(
            dialect: dialect,
            isSelected: dialect.name == selectedName,
            canDelete: viewModel.canDelete(dialect, among: allLanguages),
            onSelect: {
                onSelect(dialect)
                dismiss()
            },
            onEdit: { viewModel.startEditing(dialect) },
            onDelete: { viewModel.delete(dialect, context: modelContext) }
        )
    }
}

private struct LanguagePickerListRow: View {
    let dialect: LanguageDialect
    let isSelected: Bool
    let canDelete: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Text(dialect.flagEmoji).font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(dialect.name).foregroundStyle(.primary)
                    if dialect.isCustom {
                        Text("Custom dialect").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark").foregroundStyle(.tint)
                }
            }
        }
        .swipeActions(edge: .trailing) {
            if canDelete {
                Button("Delete", role: .destructive, action: onDelete)
            }
            Button("Edit", action: onEdit).tint(.blue)
        }
    }
}
