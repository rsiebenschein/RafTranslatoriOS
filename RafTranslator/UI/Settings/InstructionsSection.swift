import SwiftUI

/// "Gemini Instructions Template" card: editable prompt with a `{{language}}` placeholder and a
/// one-tap reset to the shipped default.
struct InstructionsSection: View {
    let viewModel: SettingsViewModel

    var body: some View {
        Section {
            TextEditor(text: Binding(
                get: { viewModel.draft.instructions },
                set: { viewModel.draft.instructions = $0 }
            ))
            .frame(minHeight: 160)
            .fontDesign(.monospaced)
            .font(.caption)

            Button("Reset to Default", role: .destructive) {
                viewModel.resetInstructions()
            }
        } header: {
            Text("Gemini Instructions Template")
        } footer: {
            Text("Use the {{language}} placeholder — it's replaced with your selected target language.")
        }
    }
}
