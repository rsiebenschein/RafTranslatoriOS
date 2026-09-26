import Foundation

/// Granular failure reasons for an in-app dictation session.
enum DictationError: Error, LocalizedError {
    case speechPermissionDenied
    case microphonePermissionDenied
    case noRecognizerAvailable
    case audioEngineStartFailed(Error)
    case recognitionFailed(Error)

    var errorDescription: String? {
        switch self {
        case .speechPermissionDenied:
            return "Speech recognition permission was denied. Enable it in Settings to dictate."
        case .microphonePermissionDenied:
            return "Microphone permission was denied. Enable it in Settings to dictate."
        case .noRecognizerAvailable:
            return "No speech recognizer is available for German or English on this device right now."
        case .audioEngineStartFailed(let underlying):
            return "Could not start the microphone: \(underlying.localizedDescription)"
        case .recognitionFailed(let underlying):
            return "Speech recognition failed: \(underlying.localizedDescription)"
        }
    }
}
