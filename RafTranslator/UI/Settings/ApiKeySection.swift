import SwiftUI
import UIKit

/// "Google Account & API Key" card: AI Studio link, key entry with show/hide + paste, and a
/// configured/missing status line.
struct ApiKeySection: View {
    let viewModel: SettingsViewModel

    @State private var isKeyVisible = false

    private static let aiStudioURL = URL(string: "https://aistudio.google.com/app/apikey")!

    var body: some View {
        Section {
            Link(destination: Self.aiStudioURL) {
                Label("Log in & Get Gemini API Key", systemImage: "person.circle")
            }

            HStack {
                apiKeyField
                Button {
                    isKeyVisible.toggle()
                } label: {
                    Image(systemName: isKeyVisible ? "eye.slash" : "eye")
                }
                .buttonStyle(.plain)
                Button {
                    if let pasted = UIPasteboard.general.string {
                        viewModel.pasteApiKey(pasted)
                    }
                } label: {
                    Image(systemName: "doc.on.clipboard")
                }
                .buttonStyle(.plain)
            }

            statusLine
        } header: {
            Text("Google Account & API Key")
        } footer: {
            Text("Enter your Google AI Studio Gemini API key. It's stored securely in the Keychain.")
        }
    }

    @ViewBuilder
    private var apiKeyField: some View {
        let binding = Binding(get: { viewModel.draft.apiKey }, set: { viewModel.draft.apiKey = $0 })
        if isKeyVisible {
            TextField("AIzaSy...", text: binding)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        } else {
            SecureField("AIzaSy...", text: binding)
        }
    }

    @ViewBuilder
    private var statusLine: some View {
        let key = viewModel.draft.apiKey.trimmingCharacters(in: .whitespaces)
        if key.isEmpty {
            Label("No API key configured. An API key is needed to translate.", systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)
                .font(.caption)
        } else {
            Label("API Key configured (\(maskedKey(key)))", systemImage: "checkmark.circle")
                .foregroundStyle(.green)
                .font(.caption)
        }
    }

    private func maskedKey(_ key: String) -> String {
        guard key.count > 8 else { return key }
        return "\(key.prefix(4))...\(key.suffix(4))"
    }
}
