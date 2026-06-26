import Foundation
import XCTest
@testable import WinmacAppSupport
import WinmacCore

@MainActor
final class LibraryViewModelTests: XCTestCase {
    func testScanLoadsGamesAndSelectsFirstGame() async {
        let games = [
            SteamGame(
                appID: "480",
                name: "Spacewar",
                installDirectoryName: "Spacewar",
                libraryPath: "/Steam",
                manifestPath: "/Steam/steamapps/appmanifest_480.acf",
                installedPath: "/Steam/steamapps/common/Spacewar"
            )
        ]
        let viewModel = LibraryViewModel(service: MockGameLibraryService(result: .success(games)))

        await viewModel.scan(steamRootPath: "/Steam")

        XCTAssertEqual(viewModel.games, games)
        XCTAssertEqual(viewModel.selectedGame, games[0])
        XCTAssertEqual(viewModel.loadState, .idle)
    }

    func testSearchFiltersByNameAndAppID() async {
        let games = [
            SteamGame(appID: "480", name: "Spacewar", installDirectoryName: "Spacewar", libraryPath: "/Steam", manifestPath: "/Steam/a.acf", installedPath: "/Steam/Spacewar"),
            SteamGame(appID: "620", name: "Portal 2", installDirectoryName: "Portal 2", libraryPath: "/Steam", manifestPath: "/Steam/b.acf", installedPath: "/Steam/Portal 2"),
            SteamGame(appID: "2371090", name: "Steam App 2371090", installDirectoryName: "Not installed", libraryPath: "/Steam", manifestPath: "/Steam/localconfig.vdf", installedPath: "", isInstalled: false, source: .localConfig)
        ]
        let viewModel = LibraryViewModel(service: MockGameLibraryService(result: .success(games)))

        await viewModel.scan(steamRootPath: "/Steam")
        viewModel.searchText = "620"

        XCTAssertEqual(viewModel.filteredGames.map(\.name), ["Portal 2"])
    }

    func testSearchFindsLocalConfigOnlyAppsByAppID() async {
        let games = [
            SteamGame(appID: "2371090", name: "Steam App 2371090", installDirectoryName: "Not installed", libraryPath: "/Steam", manifestPath: "/Steam/localconfig.vdf", installedPath: "", isInstalled: false, source: .localConfig)
        ]
        let viewModel = LibraryViewModel(service: MockGameLibraryService(result: .success(games)))

        await viewModel.scan(steamRootPath: "/Steam")
        viewModel.searchText = "2371090"

        XCTAssertEqual(viewModel.filteredGames.map(\.appID), ["2371090"])
        XCTAssertFalse(viewModel.filteredGames[0].isInstalled)
    }
}

private struct MockGameLibraryService: GameLibraryProviding {
    let result: Result<[SteamGame], Error>

    func scanGames(steamRoot: URL?) async throws -> [SteamGame] {
        try result.get()
    }
}