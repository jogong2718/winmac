import Foundation

public enum RuntimeManifestValidationError: Error, LocalizedError, Equatable {
    case emptyField(String)
    case invalidURL(String)
    case invalidSHA256(String)

    public var errorDescription: String? {
        switch self {
        case let .emptyField(field):
            return "Runtime manifest field is empty: \(field)."
        case let .invalidURL(url):
            return "Runtime manifest URL is invalid: \(url)."
        case let .invalidSHA256(value):
            return "Runtime manifest SHA-256 value is invalid: \(value)."
        }
    }
}

public struct RuntimeManifestValidator: Sendable {
    public init() {}

    public func validate(_ manifest: RuntimeManifest) throws {
        try require(manifest.component, field: "component")
        try require(manifest.version, field: "version")
        try require(manifest.platform, field: "platform")
        try require(manifest.architecture, field: "architecture")
        try require(manifest.downloadURL, field: "downloadURL")
        try require(manifest.sha256, field: "sha256")
        try require(manifest.license, field: "license")
        try require(manifest.licenseURL, field: "licenseURL")
        try require(manifest.unpackStrategy, field: "unpackStrategy")

        guard URL(string: manifest.downloadURL)?.scheme?.hasPrefix("http") == true else {
            throw RuntimeManifestValidationError.invalidURL(manifest.downloadURL)
        }

        guard URL(string: manifest.licenseURL)?.scheme?.hasPrefix("http") == true else {
            throw RuntimeManifestValidationError.invalidURL(manifest.licenseURL)
        }

        let shaPattern = #"^[a-fA-F0-9]{64}$"#
        guard manifest.sha256.range(of: shaPattern, options: .regularExpression) != nil else {
            throw RuntimeManifestValidationError.invalidSHA256(manifest.sha256)
        }
    }

    private func require(_ value: String, field: String) throws {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw RuntimeManifestValidationError.emptyField(field)
        }
    }
}