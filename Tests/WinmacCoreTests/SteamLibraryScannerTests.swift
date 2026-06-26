import XCTest
@testable import WinmacCore

final class SteamLibraryScannerTests: XCTestCase {
    func testScansSteamLibraryFoldersAndAppManifests() throws {
        let rootURL = try makeTemporaryDirectory()
        let externalURL = try makeTemporaryDirectory()
        let steamAppsURL = rootURL.appendingPathComponent("steamapps")
        let externalSteamAppsURL = externalURL.appendingPathComponent("steamapps")
        let commonURL = steamAppsURL.appendingPathComponent("common")
        let externalCommonURL = externalSteamAppsURL.appendingPathComponent("common")

        try FileManager.default.createDirectory(at: commonURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: externalCommonURL, withIntermediateDirectories: true)

        try write(
            """
            "libraryfolders"
            {
                "0"
                {
                    "path" "\(rootURL.path)"
                }
                "1"
                {
                    "path" "\(externalURL.path)"
                }
            }
            """,
            to: steamAppsURL.appendingPathComponent("libraryfolders.vdf")
        )

        try write(appManifest(appID: "480", name: "Spacewar", installDirectoryName: "Spacewar"), to: steamAppsURL.appendingPathComponent("appmanifest_480.acf"))
        try write(appManifest(appID: "620", name: "Portal 2", installDirectoryName: "Portal 2"), to: externalSteamAppsURL.appendingPathComponent("appmanifest_620.acf"))

        let games = try SteamLibraryScanner().scan(steamRoot: rootURL)

        XCTAssertEqual(games.map(\.appID), ["620", "480"])
        XCTAssertEqual(games.map(\.name), ["Portal 2", "Spacewar"])
        XCTAssertEqual(games[0].installedPath, externalCommonURL.appendingPathComponent("Portal 2").path)
        XCTAssertEqual(games[1].installedPath, commonURL.appendingPathComponent("Spacewar").path)
    }

    func testParsesLegacyLibraryFolderString() throws {
        let rootURL = try makeTemporaryDirectory()
        let externalURL = try makeTemporaryDirectory()
        let steamAppsURL = rootURL.appendingPathComponent("steamapps")
        try FileManager.default.createDirectory(at: steamAppsURL, withIntermediateDirectories: true)

        try write(
            """
            "LibraryFolders"
            {
                "1" "\(externalURL.path)"
            }
            """,
            to: steamAppsURL.appendingPathComponent("libraryfolders.vdf")
        )

        let libraries = try SteamLibraryScanner().discoverLibraries(steamRoot: rootURL)

        XCTAssertEqual(libraries.map(\.path), [externalURL.standardizedFileURL.path])
    }

    func testIncludesUninstalledAppsFromLocalConfig() throws {
        let rootURL = try makeTemporaryDirectory()
        let steamAppsURL = rootURL.appendingPathComponent("steamapps")
        let localConfigURL = rootURL
            .appendingPathComponent("userdata")
            .appendingPathComponent("123")
            .appendingPathComponent("config")
            .appendingPathComponent("localconfig.vdf")

        try FileManager.default.createDirectory(at: steamAppsURL, withIntermediateDirectories: true)
        try write(
            """
            "libraryfolders"
            {
                "0"
                {
                    "path" "\(rootURL.path)"
                }
            }
            """,
            to: steamAppsURL.appendingPathComponent("libraryfolders.vdf")
        )
        try write(appManifest(appID: "480", name: "Spacewar", installDirectoryName: "Spacewar"), to: steamAppsURL.appendingPathComponent("appmanifest_480.acf"))
        try write(
            """
            "UserLocalConfigStore"
            {
                "Software"
                {
                    "Valve"
                    {
                        "Steam"
                        {
                            "apps"
                            {
                                "7"
                                {
                                    "cloud" { }
                                }
                                "480"
                                {
                                    "LastPlayed" "1"
                                }
                                "2371090"
                                {
                                    "cloud" { }
                                }
                            }
                        }
                    }
                }
            }
            """,
            to: localConfigURL
        )

        let games = try SteamLibraryScanner().scan(steamRoot: rootURL)
        let uninstalledGame = try XCTUnwrap(games.first { $0.appID == "2371090" })

        XCTAssertEqual(games.filter { $0.appID == "480" }.count, 1)
        XCTAssertNil(games.first { $0.appID == "7" })
        XCTAssertEqual(uninstalledGame.name, "Steam App 2371090")
        XCTAssertFalse(uninstalledGame.isInstalled)
        XCTAssertEqual(uninstalledGame.source, .localConfig)
        XCTAssertEqual(uninstalledGame.manifestPath, localConfigURL.standardizedFileURL.path)
    }

    private func appManifest(appID: String, name: String, installDirectoryName: String) -> String {
        """
        "AppState"
        {
            "appid" "\(appID)"
            "name" "\(name)"
            "installdir" "\(installDirectoryName)"
            "StateFlags" "4"
        }
        """
    }
}