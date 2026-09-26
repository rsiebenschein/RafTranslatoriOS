import SwiftUI
import SwiftData

/// The full settings screen: target language, usage/billing, add-language, API key, model
/// selection, and the instructions template. Mirrors the Android app's `SettingsScreen`, with the
/// "Accessibility Floating Button" / target-app-picker section deliberately omitted for this phase.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LanguageDialect.name) private var allLanguages: [LanguageDialect]
    @State private var viewModel = SettingsViewModel()
    @State private var showSavedAlert = false

    var body: some View {
        Form {
            TargetLanguageSection(viewModel: viewModel, allLanguages: allLanguages)
            UsageSummarySection(viewModel: viewModel)
            AddLanguageSection(viewModel: viewModel)
            ApiKeySection(viewModel: viewModel)
            ModelSection(viewModel: viewModel)
            InstructionsSection(viewModel: viewModel)
            saveSection
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { saveAndConfirm() }
            }
        }
        .onAppear {
            viewModel.reload()
            viewModel.loadUsageSummary(context: modelContext)
        }
        .alert(
            "Settings",
            isPresented: $showSavedAlert,
            presenting: viewModel.saveConfirmationMessage
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    private var saveSection: some View {
        Section {
            Button {
                saveAndConfirm()
            } label: {
                Label("Save & Apply Settings", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func saveAndConfirm() {
        viewModel.save()
        showSavedAlert = viewModel.saveConfirmationMessage != nil
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
