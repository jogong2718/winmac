import Foundation

public enum SteamLibraryScannerError: Error, LocalizedError, Equatable {
    case missingLibraryFolders(String)
    case invalidLibraryFolders(String)

    public var errorDescription: String? {
        switch self {
        case let .missingLibraryFolders(path):
            return "Steam library folders file was not found at \(path)."
        case let .invalidLibraryFolders(path):
            return "Steam library folders file could not be parsed at \(path)."
        }
    }
}

public struct SteamLibraryScanner {
    private let fileManager: FileManager
    private let parser: VDFParser
    private let excludedLocalConfigAppIDs: Set<String> = ["7", "760"]

    public init(fileManager: FileManager = .default, parser: VDFParser = VDFParser()) {
        self.fileManager = fileManager
        self.parser = parser
    }

    public func defaultSteamRoot() -> URL {
        fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("Steam")
    }

    public func scan(steamRoot: URL? = nil) throws -> [SteamGame] {
        let rootURL = steamRoot ?? defaultSteamRoot()
        let libraries = try discoverLibraries(steamRoot: rootURL)
        var games: [SteamGame] = []

        for library in libraries {
            let steamAppsURL = URL(fileURLWithPath: library.steamAppsPath)
            let manifestURLs = try manifestURLs(in: steamAppsURL)

            for manifestURL in manifestURLs {
                if let game = try parseGameManifest(manifestURL: manifestURL, library: library) {
                    games.append(game)
                }
            }
        }

        let installedAppIDs = Set(games.map(\.appID))
        games.append(contentsOf: try localConfigGames(steamRoot: rootURL, excluding: installedAppIDs))

        return games.sorted { firstGame, secondGame in
            firstGame.name.localizedCaseInsensitiveCompare(secondGame.name) == .orderedAscending
        }
    }

    public func discoverLibraries(steamRoot: URL? = nil) throws -> [SteamLibrary] {
        let rootURL = steamRoot ?? defaultSteamRoot()
        let libraryFoldersURL = rootURL
            .appendingPathComponent("steamapps")
            .appendingPathComponent("libraryfolders.vdf")

        guard fileManager.fileExists(atPath: libraryFoldersURL.path) else {
            throw SteamLibraryScannerError.missingLibraryFolders(libraryFoldersURL.path)
        }

        let contents = try String(contentsOf: libraryFoldersURL, encoding: .utf8)
        let parsed = try parser.parse(contents)

        guard let libraryFoldersNode = parsed.child(named: "libraryfolders") else {
            throw SteamLibraryScannerError.invalidLibraryFolders(libraryFoldersURL.path)
        }

        var libraries: [SteamLibrary] = []

        for (identifier, child) in libraryFoldersNode.children {
            guard let path = child.value(named: "path") else { continue }
            libraries.append(library(identifier: identifier, path: path))
        }

        for (identifier, path) in libraryFoldersNode.values where identifier != "TimeNextStatsReport" {
            libraries.append(library(identifier: identifier, path: path))
        }

        if libraries.isEmpty {
            libraries.append(library(identifier: "0", path: rootURL.path))
        }

        return deduplicatedLibraries(libraries).sorted { $0.id.localizedStandardCompare($1.id) == .orderedAscending }
    }

    private func library(identifier: String, path: String) -> SteamLibrary {
        let expandedPath = expandedPath(path)
        return SteamLibrary(
            id: identifier,
            path: expandedPath,
            steamAppsPath: URL(fileURLWithPath: expandedPath).appendingPathComponent("steamapps").path
        )
    }

    private func manifestURLs(in steamAppsURL: URL) throws -> [URL] {
        guard fileManager.fileExists(atPath: steamAppsURL.path) else {
            return []
        }

        let contents = try fileManager.contentsOfDirectory(
            at: steamAppsURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        return contents
            .filter { url in
                url.lastPathComponent.hasPrefix("appmanifest_") && url.pathExtension == "acf"
            }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private func parseGameManifest(manifestURL: URL, library: SteamLibrary) throws -> SteamGame? {
        let contents = try String(contentsOf: manifestURL, encoding: .utf8)
        let parsed = try parser.parse(contents)
        guard let appState = parsed.child(named: "AppState") else { return nil }

        guard
            let appID = appState.value(named: "appid"),
            let name = appState.value(named: "name"),
            let installDirectoryName = appState.value(named: "installdir")
        else {
            return nil
        }

        let installedPath = URL(fileURLWithPath: library.steamAppsPath)
            .appendingPathComponent("common")
            .appendingPathComponent(installDirectoryName)
            .path

        return SteamGame(
            appID: appID,
            name: name,
            installDirectoryName: installDirectoryName,
            libraryPath: library.path,
            manifestPath: manifestURL.path,
            installedPath: installedPath,
            stateFlags: appState.value(named: "StateFlags")
        )
    }

    private func localConfigGames(steamRoot: URL, excluding installedAppIDs: Set<String>) throws -> [SteamGame] {
        let userdataURL = steamRoot.appendingPathComponent("userdata", isDirectory: true)

        guard fileManager.fileExists(atPath: userdataURL.path) else {
            return []
        }

        let accountDirectories = try fileManager.contentsOfDirectory(
            at: userdataURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        var gamesByAppID: [String: SteamGame] = [:]

        for accountDirectory in accountDirectories {
            guard (try? accountDirectory.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
                continue
            }

            let localConfigURL = accountDirectory
                .appendingPathComponent("config", isDirectory: true)
                .appendingPathComponent("localconfig.vdf")

            guard fileManager.fileExists(atPath: localConfigURL.path) else {
                continue
            }

            let contents = try String(contentsOf: localConfigURL, encoding: .utf8)
            let parsed = try parser.parse(contents)

            guard
                let appsNode = parsed
                    .child(named: "UserLocalConfigStore")?
                    .child(named: "Software")?
                    .child(named: "Valve")?
                    .child(named: "Steam")?
                    .child(named: "apps")
            else {
                continue
            }

            for appID in appsNode.children.keys where shouldIncludeLocalConfigAppID(appID, installedAppIDs: installedAppIDs) {
                gamesByAppID[appID] = SteamGame(
                    appID: appID,
                    name: "Steam App \(appID)",
                    installDirectoryName: "Not installed",
                    libraryPath: steamRoot.standardizedFileURL.path,
                    manifestPath: localConfigURL.standardizedFileURL.path,
                    installedPath: "",
                    stateFlags: nil,
                    isInstalled: false,
                    source: .localConfig
                )
            }
        }

        return Array(gamesByAppID.values)
    }

    private func shouldIncludeLocalConfigAppID(_ appID: String, installedAppIDs: Set<String>) -> Bool {
        appID.allSatisfy(\.isNumber)
            && !installedAppIDs.contains(appID)
            && !excludedLocalConfigAppIDs.contains(appID)
    }

    private func expandedPath(_ path: String) -> String {
        if path == "~" {
            return fileManager.homeDirectoryForCurrentUser.path
        }

        if path.hasPrefix("~/") {
            return fileManager.homeDirectoryForCurrentUser.path + String(path.dropFirst())
        }

        return URL(fileURLWithPath: path).standardizedFileURL.path
    }

    private func deduplicatedLibraries(_ libraries: [SteamLibrary]) -> [SteamLibrary] {
        var seenPaths: Set<String> = []
        var result: [SteamLibrary] = []

        for library in libraries {
            guard !seenPaths.contains(library.path) else { continue }
            seenPaths.insert(library.path)
            result.append(library)
        }

        return result
    }
}