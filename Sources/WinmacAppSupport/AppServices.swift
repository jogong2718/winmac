import Foundation
import WinmacCore

public protocol GameLibraryProviding {
    func scanGames(steamRoot: URL?) async throws -> [SteamGame]
}

public protocol BottleValidating {
    func validateBottle(prefixURL: URL) async -> BottleValidation
}

public protocol LaunchPlanBuilding {
    func makePlan(executableURL: URL, prefixURL: URL, validateInputs: Bool) async throws -> LaunchPlan
}

public protocol DiagnosticsProviding {
    func makeReport(notes: [String]) async -> DiagnosticReport
    func export(report: DiagnosticReport, to outputURL: URL) async throws
}

public protocol RuntimeManifestChecking {
    func validate(_ manifest: RuntimeManifest) throws
}

public struct GameLibraryService: GameLibraryProviding {
    public init() {}

    public func scanGames(steamRoot: URL? = nil) async throws -> [SteamGame] {
        try await Task.detached(priority: .userInitiated) {
            try SteamLibraryScanner().scan(steamRoot: steamRoot)
        }.value
    }
}

public struct BottleService: BottleValidating {
    public init() {}

    public func validateBottle(prefixURL: URL) async -> BottleValidation {
        await Task.detached(priority: .userInitiated) {
            BottleManager().validate(prefixURL: prefixURL)
        }.value
    }
}

public struct LaunchPlanService: LaunchPlanBuilding {
    public init() {}

    public func makePlan(executableURL: URL, prefixURL: URL, validateInputs: Bool = true) async throws -> LaunchPlan {
        try await Task.detached(priority: .userInitiated) {
            try LaunchPlanner().makePlan(
                executableURL: executableURL,
                prefixURL: prefixURL,
                validateInputs: validateInputs
            )
        }.value
    }
}

public struct DiagnosticsService: DiagnosticsProviding {
    public init() {}

    public func makeReport(notes: [String] = []) async -> DiagnosticReport {
        await Task.detached(priority: .userInitiated) {
            DiagnosticsExporter().makeReport(notes: notes)
        }.value
    }

    public func export(report: DiagnosticReport, to outputURL: URL) async throws {
        try await Task.detached(priority: .userInitiated) {
            try DiagnosticsExporter().export(report: report, to: outputURL)
        }.value
    }
}

public struct RuntimeManifestService: RuntimeManifestChecking {
    public init() {}

    public func validate(_ manifest: RuntimeManifest) throws {
        try RuntimeManifestValidator().validate(manifest)
    }
}