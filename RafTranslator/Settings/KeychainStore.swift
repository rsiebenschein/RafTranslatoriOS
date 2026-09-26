import Foundation
import Security

/// Thin wrapper around the Keychain Services API for storing a single string secret per account,
/// scoped to this app's bundle identifier. Used for the Gemini API key — an improvement over the
/// Android app's known plaintext-SharedPreferences storage of the same value.
enum KeychainStore {
    private static let service = Bundle.main.bundleIdentifier ?? "com.rafapps.raftranslator"

    static func save(_ value: String, account: String) throws {
        guard let data = value.data(using: .utf8) else { throw KeychainError.stringEncodingFailed }
        if try load(account: account) != nil {
            try update(data, account: account)
        } else {
            try add(data, account: account)
        }
    }

    static func load(account: String) throws -> String? {
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.unexpectedStatus(status)
        }
        return String(data: data, encoding: .utf8)
    }

    static func delete(account: String) throws {
        let status = SecItemDelete(baseQuery(account: account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private static func add(_ data: Data, account: String) throws {
        var query = baseQuery(account: account)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    private static func update(_ data: Data, account: String) throws {
        let status = SecItemUpdate(
            baseQuery(account: account) as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    private static func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
