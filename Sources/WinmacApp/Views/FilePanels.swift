import AppKit
import Foundation
import UniformTypeIdentifiers

enum FilePanels {
    static func chooseFolder(message: String) -> URL? {
        let panel = NSOpenPanel()
        panel.message = message
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func chooseFile(message: String) -> URL? {
        let panel = NSOpenPanel()
        panel.message = message
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func saveJSON(message: String, defaultName: String) -> URL? {
        let panel = NSSavePanel()
        panel.message = message
        panel.nameFieldStringValue = defaultName
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        return panel.runModal() == .OK ? panel.url : nil
    }
}