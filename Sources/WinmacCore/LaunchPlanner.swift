import Foundation

public enum LaunchPlannerError: Error, LocalizedError, Equatable {
    case executableMissing(String)
    case invalidPrefix(String)

    public var errorDescription: String? {
        switch self {
        case let .executableMissing(path):
            return "Executable does not exist at \(path)."
        case let .invalidPrefix(path):
            return "Wine prefix is not valid at \(path)."
        }
    }
}

public struct LaunchPlanner: Sendable {
    private let fileManager: FileManager
    private let bottleManager: BottleManager

    public init(fileManager: FileManager = .default, bottleManager: BottleManager = BottleManager()) {
        self.fileManager = fileManager
        self.bottleManager = bottleManager
    }

    public func mergedProfile(_ profiles: [LaunchProfile]) -> LaunchProfile {
        var merged = LaunchProfile()
        var serializedOverrides: [String] = []

        for profile in profiles {
            merged.environment.merge(profile.environment) { _, newerValue in newerValue }
            merged.dllOverrides.merge(profile.dllOverrides) { _, newerValue in newerValue }
            merged.arguments.append(contentsOf: profile.arguments)

            if let existingOverrides = profile.environment["WINEDLLOVERRIDES"], !existingOverrides.isEmpty {
                serializedOverrides.append(existingOverrides)
            }
        }

        if !merged.dllOverrides.isEmpty {
            let overrideValue = merged.dllOverrides
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ";")

            serializedOverrides.append(overrideValue)
        }

        if !serializedOverrides.isEmpty {
            merged.environment["WINEDLLOVERRIDES"] = serializedOverrides.joined(separator: ";")
        }

        return merged
    }

    public func makePlan(
        executableURL: URL,
        prefixURL: URL,
        profiles: [LaunchProfile] = [.winmacDefaults],
        workingDirectory: URL? = nil,
        validateInputs: Bool = true
    ) throws -> LaunchPlan {
        let executablePath = executableURL.standardizedFileURL.path
        let prefixPath = prefixURL.standardizedFileURL.path

        if validateInputs, fileManager.fileExists(atPath: executablePath) == false {
            throw LaunchPlannerError.executableMissing(executablePath)
        }

        if validateInputs {
            let validation = bottleManager.validate(prefixURL: prefixURL)
            if validation.isValid == false {
                throw LaunchPlannerError.invalidPrefix(prefixPath)
            }
        }

        let merged = mergedProfile(profiles)
        var environment = merged.environment
        environment["WINEPREFIX"] = prefixPath
        environment["WINEARCH"] = "win64"

        return LaunchPlan(
            executablePath: executablePath,
            prefixPath: prefixPath,
            workingDirectory: (workingDirectory ?? executableURL.deletingLastPathComponent()).standardizedFileURL.path,
            environment: environment,
            arguments: merged.arguments
        )
    }
}