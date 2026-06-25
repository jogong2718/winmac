import Foundation

public struct BottleManager: Sendable {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func validate(prefixURL: URL) -> BottleValidation {
        let standardizedURL = prefixURL.standardizedFileURL
        let path = standardizedURL.path
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
        let driveCPath = standardizedURL.appendingPathComponent("drive_c").path
        let userRegistryPath = standardizedURL.appendingPathComponent("user.reg").path
        let systemRegistryPath = standardizedURL.appendingPathComponent("system.reg").path

        let hasDriveC = isDirectoryPath(driveCPath)
        let hasUserRegistry = fileManager.fileExists(atPath: userRegistryPath)
        let hasSystemRegistry = fileManager.fileExists(atPath: systemRegistryPath)
        let architecture = hasSystemRegistry ? detectArchitecture(systemRegistryURL: URL(fileURLWithPath: systemRegistryPath)) : .unknown
        let isWritable = exists && fileManager.isWritableFile(atPath: path)
        let brokenSymlinks = exists ? findBrokenSymlinks(under: standardizedURL) : []

        return BottleValidation(
            path: path,
            exists: exists,
            hasDriveC: hasDriveC,
            hasUserRegistry: hasUserRegistry,
            hasSystemRegistry: hasSystemRegistry,
            architecture: architecture,
            isWritable: isWritable,
            brokenSymlinks: brokenSymlinks
        )
    }

    private func isDirectoryPath(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return fileManager.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    private func detectArchitecture(systemRegistryURL: URL) -> BottleArchitecture {
        guard let handle = try? FileHandle(forReadingFrom: systemRegistryURL) else {
            return .unknown
        }

        defer { try? handle.close() }
        let data = handle.readData(ofLength: 4096)
        guard let prefix = String(data: data, encoding: .utf8)?.lowercased() else {
            return .unknown
        }

        if prefix.contains("#arch=win64") || prefix.contains("win64") {
            return .win64
        }

        if prefix.contains("#arch=win32") || prefix.contains("win32") {
            return .win32
        }

        return .unknown
    }

    private func findBrokenSymlinks(under rootURL: URL) -> [String] {
        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isSymbolicLinkKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var brokenPaths: [String] = []

        for case let itemURL as URL in enumerator {
            guard (try? itemURL.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true else {
                continue
            }

            guard let destination = try? fileManager.destinationOfSymbolicLink(atPath: itemURL.path) else {
                brokenPaths.append(itemURL.path)
                continue
            }

            let destinationURL: URL
            if destination.hasPrefix("/") {
                destinationURL = URL(fileURLWithPath: destination)
            } else {
                destinationURL = itemURL.deletingLastPathComponent().appendingPathComponent(destination)
            }

            if fileManager.fileExists(atPath: destinationURL.standardizedFileURL.path) == false {
                brokenPaths.append(itemURL.path)
            }
        }

        return brokenPaths.sorted()
    }
}