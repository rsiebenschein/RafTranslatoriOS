import Foundation
import Speech
import AVFoundation

/// Locale resolution and permission requests for `DictationService`.
extension DictationService {
    /// The first preferred locale (`de-CH` → `de-DE` → `en-US`) that has an available recognizer
    /// on this device, or nil if none do.
    func resolvePreferredRecognizer() -> SFSpeechRecognizer? {
        for identifier in Self.preferredLocaleIdentifiers {
            let locale = Locale(identifier: identifier)
            if let candidate = SFSpeechRecognizer(locale: locale), candidate.isAvailable {
                return candidate
            }
        }
        return nil
    }

    func requestSpeechAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func requestMicrophoneAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
