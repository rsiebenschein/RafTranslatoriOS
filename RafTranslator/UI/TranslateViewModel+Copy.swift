import Foundation
import UIKit

/// Copy-to-clipboard for `TranslateViewModel`, mirroring the Android app's "Copied! ✓" flash.
extension TranslateViewModel {
    private static let copiedFlashDuration: UInt64 = 2_000_000_000

    @MainActor
    func copyTranslationToClipboard() {
        guard let text = translationResult?.text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        isCopied = true
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: Self.copiedFlashDuration)
            self?.isCopied = false
        }
    }
}
