import Foundation

public final class UserSettings: ObservableObject {
    private enum Key {
        static let steamRootPath = "steamRootPath"
        static let defaultBottlePath = "defaultBottlePath"
        static let showRawJSON = "showRawJSON"
    }

    private let defaults: UserDefaults

    @Published public var steamRootPath: String {
        didSet { defaults.set(steamRootPath, forKey: Key.steamRootPath) }
    }

    @Published public var defaultBottlePath: String {
        didSet { defaults.set(defaultBottlePath, forKey: Key.defaultBottlePath) }
    }

    @Published public var showRawJSON: Bool {
        didSet { defaults.set(showRawJSON, forKey: Key.showRawJSON) }
    }

    public init(defaults: UserDefaults = .standard, fileManager: FileManager = .default) {
        self.defaults = defaults
        let home = fileManager.homeDirectoryForCurrentUser
        let fallbackSteamRoot = home
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("Steam")
            .path
        let fallbackBottlePath = home
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("Winmac")
            .appendingPathComponent("bottles")
            .path

        self.steamRootPath = defaults.string(forKey: Key.steamRootPath) ?? fallbackSteamRoot
        self.defaultBottlePath = defaults.string(forKey: Key.defaultBottlePath) ?? fallbackBottlePath
        self.showRawJSON = defaults.object(forKey: Key.showRawJSON) as? Bool ?? false
    }
}