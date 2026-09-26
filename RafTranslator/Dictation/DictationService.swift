import Foundation
import Speech
import AVFoundation
import Observation

/// In-app dictation session, replacing Android's fire-and-forget `RecognizerIntent` system
/// activity. iOS has no equivalent dictation *activity* to launch, so this drives a live
/// `AVAudioEngine` capture + `SFSpeechRecognizer` session instead, exposing live partial and
/// final transcript state for a record button UI.
///
/// Locale fallback mirrors the Android app's chain (`de-CH` → `de-DE` → `en-US`): tries each in
/// order and uses the first one the device actually supports and has resources available for.
@Observable
@MainActor
final class DictationService: NSObject {
    static let preferredLocaleIdentifiers = ["de-CH", "de-DE", "en-US"]

    private(set) var isRecording = false
    private(set) var transcript = ""
    private(set) var lastError: DictationError?

    private var recognizer: SFSpeechRecognizer?
    let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestAuthorization() async -> Bool {
        let speechGranted = await requestSpeechAuthorization()
        let microphoneGranted = await requestMicrophoneAuthorization()
        return speechGranted && microphoneGranted
    }

    func startRecording() throws {
        guard !isRecording else { return }
        guard let recognizer = resolvePreferredRecognizer() else {
            throw DictationError.noRecognizerAvailable
        }
        self.recognizer = recognizer
        transcript = ""
        lastError = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        try startAudioEngine(feeding: request)
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                self?.handleRecognitionUpdate(result: result, error: error)
            }
        }
        isRecording = true
    }

    func stopRecording() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }

    private func handleRecognitionUpdate(result: SFSpeechRecognitionResult?, error: Error?) {
        if let result {
            transcript = result.bestTranscription.formattedString
        }
        if let error {
            lastError = .recognitionFailed(error)
            stopRecording()
        } else if result?.isFinal == true {
            stopRecording()
        }
    }
}
