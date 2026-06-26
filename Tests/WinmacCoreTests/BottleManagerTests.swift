import XCTest
@testable import WinmacCore

final class BottleManagerTests: XCTestCase {
    func testValidatesMinimalWin64Prefix() throws {
        let prefixURL = try makeTemporaryDirectory()
        try FileManager.default.createDirectory(at: prefixURL.appendingPathComponent("drive_c"), withIntermediateDirectories: true)
        try write("#arch=win64\n", to: prefixURL.appendingPathComponent("system.reg"))
        try write("REGEDIT4\n", to: prefixURL.appendingPathComponent("user.reg"))

        let validation = BottleManager().validate(prefixURL: prefixURL)

        XCTAssertTrue(validation.isValid)
        XCTAssertEqual(validation.architecture, .win64)
        XCTAssertTrue(validation.brokenSymlinks.isEmpty)
    }

    func testReportsMissingRegistryFiles() throws {
        let prefixURL = try makeTemporaryDirectory()
        try FileManager.default.createDirectory(at: prefixURL.appendingPathComponent("drive_c"), withIntermediateDirectories: true)

        let validation = BottleManager().validate(prefixURL: prefixURL)

        XCTAssertFalse(validation.isValid)
        XCTAssertFalse(validation.hasSystemRegistry)
        XCTAssertFalse(validation.hasUserRegistry)
    }

    func testReportsBrokenSymlinks() throws {
        let prefixURL = try makeTemporaryDirectory()
        let dosDevicesURL = prefixURL.appendingPathComponent("dosdevices")
        try FileManager.default.createDirectory(at: prefixURL.appendingPathComponent("drive_c"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: dosDevicesURL, withIntermediateDirectories: true)
        try write("#arch=win64\n", to: prefixURL.appendingPathComponent("system.reg"))
        try write("REGEDIT4\n", to: prefixURL.appendingPathComponent("user.reg"))
        try FileManager.default.createSymbolicLink(
            at: dosDevicesURL.appendingPathComponent("z:"),
            withDestinationURL: prefixURL.appendingPathComponent("missing")
        )

        let validation = BottleManager().validate(prefixURL: prefixURL)

        XCTAssertFalse(validation.isValid)
        XCTAssertEqual(validation.brokenSymlinks.count, 1)
        XCTAssertTrue(validation.brokenSymlinks[0].hasSuffix("/dosdevices/z:"))
    }
}