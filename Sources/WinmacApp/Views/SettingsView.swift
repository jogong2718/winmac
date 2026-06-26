import SwiftUI
import WinmacAppSupport

struct SettingsView: View {
    @ObservedObject var settings: UserSettings

    var body: some View {
        Form {
            Section("Locations") {
                ViewThatFits(in: .horizontal) {
                    steamFolderRow
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Steam folder", text: $settings.steamRootPath)
                        chooseSteamFolderButton
                    }
                }

                ViewThatFits(in: .horizontal) {
                    bottleFolderRow
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Default bottle folder", text: $settings.defaultBottlePath)
                        chooseBottleFolderButton
                    }
                }
            }

            Section("Advanced") {
                Toggle("Show raw JSON previews", isOn: $settings.showRawJSON)
            }
        }
        .formStyle(.grouped)
    }

    private var steamFolderRow: some View {
        HStack {
            TextField("Steam folder", text: $settings.steamRootPath)
            chooseSteamFolderButton
        }
    }

    private var chooseSteamFolderButton: some View {
        Button {
            if let url = FilePanels.chooseFolder(message: "Choose your Steam folder") {
                settings.steamRootPath = url.path
            }
        } label: {
            Label("Choose", systemImage: "folder")
        }
    }

    private var bottleFolderRow: some View {
        HStack {
            TextField("Default bottle folder", text: $settings.defaultBottlePath)
            chooseBottleFolderButton
        }
    }

    private var chooseBottleFolderButton: some View {
        Button {
            if let url = FilePanels.chooseFolder(message: "Choose the default bottle folder") {
                settings.defaultBottlePath = url.path
            }
        } label: {
            Label("Choose", systemImage: "folder")
        }
    }
}