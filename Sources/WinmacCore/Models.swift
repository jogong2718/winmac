import Foundation

public struct SteamGame: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let appID: String
    public let name: String
    public let installDirectoryName: String
    public let libraryPath: String
    public let manifestPath: String
    public let installedPath: String
    public let stateFlags: String?
    public let isInstalled: Bool
    public let source: SteamGameSource

    public init(
        appID: String,
        name: String,
        installDirectoryName: String,
        libraryPath: String,
        manifestPath: String,
        installedPath: String,
        stateFlags: String? = nil,
        isInstalled: Bool = true,
        source: SteamGameSource = .appManifest
    ) {
        self.id = appID
        self.appID = appID
        self.name = name
        self.installDirectoryName = installDirectoryName
        self.libraryPath = libraryPath
        self.manifestPath = manifestPath
        self.installedPath = installedPath
        self.stateFlags = stateFlags
        self.isInstalled = isInstalled
        self.source = source
    }
}

public enum SteamGameSource: String, Codable, Equatable, Sendable {
    case appManifest
    case localConfig
}

public struct SteamLibrary: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let path: String
    public let steamAppsPath: String

    public init(id: String, path: String, steamAppsPath: String) {
        self.id = id
        self.path = path
        self.steamAppsPath = steamAppsPath
    }
}

public enum BottleArchitecture: String, Codable, Equatable, Sendable {
    case win32
    case win64
    case unknown
}

public struct BottleValidation: Codable, Equatable, Sendable {
    public let path: String
    public let exists: Bool
    public let hasDriveC: Bool
    public let hasUserRegistry: Bool
    public let hasSystemRegistry: Bool
    public let architecture: BottleArchitecture
    public let isWritable: Bool
    public let brokenSymlinks: [String]

    public var isValid: Bool {
        exists && hasDriveC && hasUserRegistry && hasSystemRegistry && isWritable && brokenSymlinks.isEmpty
    }

    public init(
        path: String,
        exists: Bool,
        hasDriveC: Bool,
        hasUserRegistry: Bool,
        hasSystemRegistry: Bool,
        architecture: BottleArchitecture,
        isWritable: Bool,
        brokenSymlinks: [String]
    ) {
        self.path = path
        self.exists = exists
        self.hasDriveC = hasDriveC
        self.hasUserRegistry = hasUserRegistry
        self.hasSystemRegistry = hasSystemRegistry
        self.architecture = architecture
        self.isWritable = isWritable
        self.brokenSymlinks = brokenSymlinks
    }
}

public struct RuntimeManifest: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let component: String
    public let version: String
    public let platform: String
    public let architecture: String
    public let downloadURL: String
    public let sha256: String
    public let license: String
    public let licenseURL: String
    public let unpackStrategy: String

    public init(
        component: String,
        version: String,
        platform: String,
        architecture: String,
        downloadURL: String,
        sha256: String,
        license: String,
        licenseURL: String,
        unpackStrategy: String
    ) {
        self.id = "\(component)-\(version)-\(platform)-\(architecture)"
        self.component = component
        self.version = version
        self.platform = platform
        self.architecture = architecture
        self.downloadURL = downloadURL
        self.sha256 = sha256
        self.license = license
        self.licenseURL = licenseURL
        self.unpackStrategy = unpackStrategy
    }
}

public struct LaunchProfile: Codable, Equatable, Sendable {
    public var environment: [String: String]
    public var dllOverrides: [String: String]
    public var arguments: [String]

    public init(
        environment: [String: String] = [:],
        dllOverrides: [String: String] = [:],
        arguments: [String] = []
    ) {
        self.environment = environment
        self.dllOverrides = dllOverrides
        self.arguments = arguments
    }

    public static let winmacDefaults = LaunchProfile(
        dllOverrides: [
            "winemenubuilder.exe": "d"
        ]
    )
}

public struct LaunchPlan: Codable, Equatable, Sendable {
    public let executablePath: String
    public let prefixPath: String
    public let workingDirectory: String
    public let environment: [String: String]
    public let arguments: [String]

    public init(
        executablePath: String,
        prefixPath: String,
        workingDirectory: String,
        environment: [String: String],
        arguments: [String]
    ) {
        self.executablePath = executablePath
        self.prefixPath = prefixPath
        self.workingDirectory = workingDirectory
        self.environment = environment
        self.arguments = arguments
    }
}

public struct DiagnosticReport: Codable, Equatable, Sendable {
    public let generatedAt: Date
    public let appVersion: String
    public let host: HostSummary
    public let notes: [String]

    public init(generatedAt: Date, appVersion: String, host: HostSummary, notes: [String]) {
        self.generatedAt = generatedAt
        self.appVersion = appVersion
        self.host = host
        self.notes = notes
    }
}

public struct HostSummary: Codable, Equatable, Sendable {
    public let operatingSystem: String
    public let architecture: String
    public let homeDirectoryRedacted: String

    public init(operatingSystem: String, architecture: String, homeDirectoryRedacted: String) {
        self.operatingSystem = operatingSystem
        self.architecture = architecture
        self.homeDirectoryRedacted = homeDirectoryRedacted
    }
}