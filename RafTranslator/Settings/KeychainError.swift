import Foundation

/// Granular Keychain failure reasons, replacing a bare `OSStatus` or generic `Error`.
enum KeychainError: Error, LocalizedError {
    case stringEncodingFailed
    case unexpectedStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .stringEncodingFailed:
            return "Could not encode the value for Keychain storage."
        case .unexpectedStatus(let status):
            let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
            return "Keychain error \(status): \(message)"
        }
    }
}
