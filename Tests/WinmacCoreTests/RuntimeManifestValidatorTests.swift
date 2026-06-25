import XCTest
@testable import WinmacCore

final class RuntimeManifestValidatorTests: XCTestCase {
    func testAcceptsCompleteRuntimeManifest() throws {
        let manifest = RuntimeManifest(
            component: "wine",
            version: "9.0",
            platform: "macos",
            architecture: "x86_64",
            downloadURL: "https://example.com/wine.tar.xz",
            sha256: String(repeating: "a", count: 64),
            license: "LGPL-2.1-or-later",
            licenseURL: "https://example.com/license.txt",
            unpackStrategy: "tar.xz"
        )

        XCTAssertNoThrow(try RuntimeManifestValidator().validate(manifest))
    }

    func testRejectsInvalidChecksum() {
        let manifest = RuntimeManifest(
            component: "wine",
            version: "9.0",
            platform: "macos",
            architecture: "x86_64",
            downloadURL: "https://example.com/wine.tar.xz",
            sha256: "not-a-checksum",
            license: "LGPL-2.1-or-later",
            licenseURL: "https://example.com/license.txt",
            unpackStrategy: "tar.xz"
        )

        XCTAssertThrowsError(try RuntimeManifestValidator().validate(manifest))
    }
}