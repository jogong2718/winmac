import XCTest
@testable import WinmacCore

final class VDFParserTests: XCTestCase {
    func testParsesNestedSteamVDF() throws {
        let source = #"""
        "libraryfolders"
        {
            "0"
            {
                "path" "/Users/example/Library/Application Support/Steam"
                "apps"
                {
                    "570" "12345"
                }
            }
        }
        """#

        let parsed = try VDFParser().parse(source)
        let libraryFolders = try XCTUnwrap(parsed.child(named: "libraryfolders"))
        let primaryLibrary = try XCTUnwrap(libraryFolders.child(named: "0"))

        XCTAssertEqual(primaryLibrary.value(named: "path"), "/Users/example/Library/Application Support/Steam")
        XCTAssertEqual(primaryLibrary.child(named: "apps")?.value(named: "570"), "12345")
    }

    func testIgnoresLineCommentsAndUnescapesStrings() throws {
        let source = #"""
        // Steam can write comments in some KeyValues files.
        "AppState"
        {
            "name" "Quoted \"Game\""
        }
        """#

        let parsed = try VDFParser().parse(source)
        let appState = try XCTUnwrap(parsed.child(named: "appstate"))

        XCTAssertEqual(appState.value(named: "name"), "Quoted \"Game\"")
    }

    func testThrowsForMissingCloseBrace() throws {
        let source = #"""
        "AppState"
        {
            "appid" "123"
        """#

        XCTAssertThrowsError(try VDFParser().parse(source)) { error in
            XCTAssertEqual(error as? VDFParserError, .unexpectedEnd)
        }
    }
}