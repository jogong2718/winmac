import Foundation
import WinmacCore

@MainActor
public final class LaunchPlanViewModel: ObservableObject {
    private let service: LaunchPlanBuilding

    @Published public var executablePath = ""
    @Published public var prefixPath = ""
    @Published public var validateInputs = true
    @Published public private(set) var launchPlan: LaunchPlan?
    @Published public private(set) var loadState: LoadState = .idle

    public init(service: LaunchPlanBuilding = LaunchPlanService()) {
        self.service = service
    }

    public var launchPlanJSON: String {
        guard let launchPlan else { return "" }
        return JSONFormatting.prettyPrinted(launchPlan)
    }

    public func buildPlan() async {
        guard let executableURL = Self.url(from: executablePath) else {
            loadState = .failed("Choose a Windows executable first.")
            launchPlan = nil
            return
        }

        guard let prefixURL = Self.url(from: prefixPath) else {
            loadState = .failed("Choose a Wine prefix folder first.")
            launchPlan = nil
            return
        }

        loadState = .loading

        do {
            launchPlan = try await service.makePlan(
                executableURL: executableURL,
                prefixURL: prefixURL,
                validateInputs: validateInputs
            )
            loadState = .idle
        } catch {
            launchPlan = nil
            loadState = .failed(error.localizedDescription)
        }
    }

    public func useExecutable(_ url: URL) {
        executablePath = url.standardizedFileURL.path
    }

    public func usePrefix(_ url: URL) {
        prefixPath = url.standardizedFileURL.path
    }

    public func useGameInstallPath(_ game: SteamGame) {
        if executablePath.isEmpty {
            executablePath = game.installedPath
        }
    }

    private static func url(from path: String) -> URL? {
        let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPath.isEmpty else { return nil }
        return URL(fileURLWithPath: NSString(string: trimmedPath).expandingTildeInPath).standardizedFileURL
    }
}