import SwiftUI

/// "Active Flash & Flash-Lite Models" card: pull live models from Gemini, then pick one.
struct ModelSection: View {
    let viewModel: SettingsViewModel

    @State private var showModelPicker = false

    var body: some View {
        Section {
            Button {
                Task { await viewModel.fetchActiveModels() }
            } label: {
                if viewModel.isFetchingModels {
                    Label("Pulling Active Flash Models...", systemImage: "arrow.triangle.2.circlepath")
                } else {
                    Label("Pull Active Flash Models from Gemini", systemImage: "arrow.triangle.2.circlepath")
                }
            }
            .disabled(viewModel.isFetchingModels || viewModel.draft.apiKey.trimmingCharacters(in: .whitespaces).isEmpty)

            if let message = viewModel.fetchModelsMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(message.hasPrefix("Success") ? .green : .red)
            }

            Button {
                showModelPicker = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Active model for translation").font(.caption).foregroundStyle(.secondary)
                        Text(viewModel.draft.selectedModel).fontDesign(.monospaced)
                    }
                    Spacer()
                    Text("Change").foregroundStyle(.tint)
                }
            }
        } header: {
            Text("Active Flash & Flash-Lite Models")
        } footer: {
            Text("Deprecated, Pro, image, and audio models are filtered out automatically.")
        }
        .sheet(isPresented: $showModelPicker) {
            ModelPickerSheet(viewModel: viewModel)
        }
    }
}

private struct ModelPickerSheet: View {
    let viewModel: SettingsViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(viewModel.modelsToDisplay) { model in
                Button {
                    viewModel.draft.selectedModel = model.id
                    dismiss()
                } label: {
                    HStack {
                        Text(model.id).fontDesign(.monospaced)
                        Spacer()
                        if model.id == viewModel.draft.selectedModel {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            .navigationTitle("Select Model")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
