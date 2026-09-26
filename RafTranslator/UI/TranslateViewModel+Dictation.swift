import Foundation

/// Dictation toggling for `TranslateViewModel`: starts/stops `DictationService` and appends its
/// transcript into `inputText`, replacing Android's single-shot `onAppendDictatedText` callback.
extension TranslateViewModel {
    @MainActor
    func toggleDictation() async {
        if dictation.isRecording {
            stopDictationAndAppendTranscript()
        } else {
            await startDictation()
        }
    }

    @MainActor
    private func startDictation() async {
        let granted = await dictation.requestAuthorization()
        guard granted else {
            translationError = DictationError.speechPermissionDenied.localizedDescription
            return
        }
        do {
            try dictation.startRecording()
        } catch {
            translationError = error.localizedDescription
        }
    }

    @MainActor
    private func stopDictationAndAppendTranscript() {
        dictation.stopRecording()
        let spoken = dictation.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !spoken.isEmpty else { return }
        inputText = inputText.isEmpty ? spoken : "\(inputText) \(spoken)"
    }
}
