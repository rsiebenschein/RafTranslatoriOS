import SwiftUI
import SwiftData

/// Primary translate action button, shared by both main screens with screen-specific label text.
struct MainTranslateButton: View {
    @Bindable var viewModel: TranslateViewModel
    let modelContext: ModelContext
    let label: String

    var body: some View {
        Button {
            Task { await viewModel.translate(modelContext: modelContext) }
        } label: {
            Label(label, systemImage: "character.bubble")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isTranslating)
    }
}
