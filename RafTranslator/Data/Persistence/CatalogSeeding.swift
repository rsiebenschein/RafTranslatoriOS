import Foundation
import SwiftData

/// Runs the catalog seeder only when its data has changed since the last successful run,
/// instead of a full pass over the catalog on every app launch.
enum CatalogSeeding {
    private static let seededVersionKey = "seeded_catalog_version"

    static func seedIfNeeded(context: ModelContext, defaults: UserDefaults = .standard) throws {
        let version = currentVersion()
        if defaults.object(forKey: seededVersionKey) != nil,
           defaults.integer(forKey: seededVersionKey) == version {
            return
        }
        try DialectSeeder.seedAndMigrate(context: context)
        try context.save()
        // Recorded only after seeding succeeded, so a failed pass is retried on the next launch.
        defaults.set(version, forKey: seededVersionKey)
    }

    /// A deterministic content hash of the seed catalog, stable across process launches
    /// (unlike Swift's randomized `Hasher`), so it can be persisted and compared later.
    private static func currentVersion() -> Int {
        var hash: UInt64 = 0xcbf29ce484222325 // FNV-1a offset basis
        for seed in DialectSeeder.seedData {
            for scalar in "\(seed.seedKey)|\(seed.promptName)|\(seed.groupKey ?? "")".utf8 {
                hash ^= UInt64(scalar)
                hash = hash &* 0x100000001b3
            }
        }
        return Int(truncatingIfNeeded: hash)
    }
}
