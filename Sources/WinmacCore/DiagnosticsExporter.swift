import Foundation

public struct DiagnosticsExporter: Sendable {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func makeReport(notes: [String] = []) -> DiagnosticReport {
        let processInfo = ProcessInfo.processInfo
        let architecture = RuntimeArchitecture.current.rawValue

        return DiagnosticReport(
            generatedAt: Date(),
            appVersion: "0.1.0-dev",
            host: HostSummary(
                operatingSystem: processInfo.operatingSystemVersionString,
                architecture: architecture,
                homeDirectoryRedacted: "~"
            ),
            notes: notes
        )
    }

    public func export(report: DiagnosticReport, to outputURL: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(report)
        let parentURL = outputURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: parentURL, withIntermediateDirectories: true)
        try data.write(to: outputURL, options: [.atomic])
    }
}

public enum RuntimeArchitecture: String, Sendable {
    case arm64
    case x86_64
    case unknown

    public static var current: RuntimeArchitecture {
        #if arch(arm64)
        return .arm64
        #elseif arch(x86_64)
        return .x86_64
        #else
        return .unknown
        #endif
    }
}