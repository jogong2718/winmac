import AppKit
import SwiftUI
import WinmacAppSupport
import WinmacCore

struct GameDetailView: View {
    let game: SteamGame?
    @ObservedObject var settings: UserSettings
    @ObservedObject var launchPlanViewModel: LaunchPlanViewModel
    @ObservedObject var bottleViewModel: BottleValidationViewModel

    var body: some View {
        if let game {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header(for: game)
                    Divider()
                    currentTools(for: game)
                    Divider()
                    launchPlanPreview
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: game.id) { _ in
                launchPlanViewModel.useGameInstallPath(game)
            }
        } else {
            EmptyStateView(
                systemImage: "rectangle.stack.badge.person.crop",
                title: "Select a Game",
                message: "Choose a Steam game from the library to inspect paths and prepare a launch plan."
            )
        }
    }

    private func header(for game: SteamGame) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    gameTitle(game.name)
                    Spacer()
                    revealButton(for: game)
                }

                VStack(alignment: .leading, spacing: 8) {
                    gameTitle(game.name)
                    revealButton(for: game)
                }
            }

            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                PathGridRow(label: "Steam App ID", value: game.appID)
                PathGridRow(label: "Status", value: game.isInstalled ? "Installed" : "Not installed on this Mac")
                if game.isInstalled {
                    PathGridRow(label: "Install Folder", value: game.installedPath)
                }
                PathGridRow(label: "Library", value: game.libraryPath)
                PathGridRow(label: game.source == .appManifest ? "Manifest" : "Local Config", value: game.manifestPath)
                if let stateFlags = game.stateFlags {
                    PathGridRow(label: "State Flags", value: stateFlags)
                }
            }

            if !game.isInstalled {
                InlineMessage(
                    systemImage: "info.circle",
                    text: "Steam has this AppID in local account config, but macOS Steam cannot install Windows-only depots. Future Winmac installs should use Windows Steam inside Wine; manual executable selection is only for files you already have."
                )
            }
        }
    }

    private func gameTitle(_ title: String) -> some View {
        Text(title)
            .font(.largeTitle.weight(.semibold))
            .lineLimit(3)
            .minimumScaleFactor(0.72)
    }

    private func revealButton(for game: SteamGame) -> some View {
        Button {
            if game.isInstalled {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: game.installedPath)
            } else {
                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: game.manifestPath)])
            }
        } label: {
            Label(game.isInstalled ? "Reveal" : "Reveal Config", systemImage: "folder")
        }
    }

    private func currentTools(for game: SteamGame) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Tools")
                .font(.title3.weight(.semibold))

            ViewThatFits(in: .horizontal) {
                currentToolsButtons(for: game)
                VStack(alignment: .leading, spacing: 8) {
                    useInstallPathButton(for: game)
                    chooseExecutableButton
                    choosePrefixButton
                }
            }

            Text("This build previews launch plans only. Wine execution comes in the runtime phase.")
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }

    private func currentToolsButtons(for game: SteamGame) -> some View {
        HStack {
            useInstallPathButton(for: game)
            chooseExecutableButton
            choosePrefixButton
        }
    }

    private func useInstallPathButton(for game: SteamGame) -> some View {
        Button {
            launchPlanViewModel.useGameInstallPath(game)
        } label: {
            Label("Use Install Path", systemImage: "arrow.down.doc")
        }
        .disabled(!game.isInstalled)
    }

    private var chooseExecutableButton: some View {
        Button {
            if let url = FilePanels.chooseFile(message: "Choose a Windows executable") {
                launchPlanViewModel.useExecutable(url)
            }
        } label: {
            Label("Choose Executable", systemImage: "doc")
        }
    }

    private var choosePrefixButton: some View {
        Button {
            if let url = FilePanels.chooseFolder(message: "Choose a Wine prefix") {
                launchPlanViewModel.usePrefix(url)
                bottleViewModel.updatePath(url)
            }
        } label: {
            Label("Choose Prefix", systemImage: "folder")
        }
    }

    private var launchPlanPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    Text("Launch Plan Preview")
                        .font(.title3.weight(.semibold))
                    Spacer()
                    buildPlanButton
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Launch Plan Preview")
                        .font(.title3.weight(.semibold))
                    buildPlanButton
                }
            }

            if let message = launchPlanViewModel.loadState.errorMessage {
                InlineMessage(systemImage: "exclamationmark.triangle", text: message)
            }

            if let launchPlan = launchPlanViewModel.launchPlan {
                LaunchPlanSummary(
                    launchPlan: launchPlan,
                    showRawJSON: settings.showRawJSON,
                    json: launchPlanViewModel.launchPlanJSON
                )
            } else {
                Text("Build a plan to preview environment variables, arguments, and the working directory.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var buildPlanButton: some View {
        Button {
            Task { await launchPlanViewModel.buildPlan() }
        } label: {
            Label("Build Plan", systemImage: "doc.text.magnifyingglass")
        }
        .disabled(launchPlanViewModel.loadState.isLoading)
    }
}