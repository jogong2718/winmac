import Foundation
import WinmacCore

@MainActor
public final class LibraryViewModel: ObservableObject {
    private let service: GameLibraryProviding

    @Published public private(set) var games: [SteamGame] = []
    @Published public var selectedGame: SteamGame?
    @Published public var searchText = ""
    @Published public private(set) var loadState: LoadState = .idle

    public init(service: GameLibraryProviding = GameLibraryService()) {
        self.service = service
    }

    public var filteredGames: [SteamGame] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return games }

        return games.filter { game in
            game.name.localizedCaseInsensitiveContains(query)
                || game.appID.localizedCaseInsensitiveContains(query)
                || game.installDirectoryName.localizedCaseInsensitiveContains(query)
        }
    }

    public func scan(steamRootPath: String? = nil) async {
        loadState = .loading

        do {
            let steamRoot = steamRootPath.flatMap(Self.url(from:))
            let scannedGames = try await service.scanGames(steamRoot: steamRoot)
            games = scannedGames

            if let selectedGame, !scannedGames.contains(where: { $0.id == selectedGame.id }) {
                self.selectedGame = scannedGames.first
            } else if selectedGame == nil {
                selectedGame = scannedGames.first
            }

            loadState = .idle
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    public func select(game: SteamGame) {
        selectedGame = game
    }

    private static func url(from path: String) -> URL? {
        let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPath.isEmpty else { return nil }
        return URL(fileURLWithPath: NSString(string: trimmedPath).expandingTildeInPath).standardizedFileURL
    }
}