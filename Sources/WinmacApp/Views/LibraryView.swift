import SwiftUI
import WinmacAppSupport
import WinmacCore

struct LibraryView: View {
    @ObservedObject var settings: UserSettings
    @ObservedObject var viewModel: LibraryViewModel
    @ObservedObject var launchPlanViewModel: LaunchPlanViewModel
    @ObservedObject var bottleViewModel: BottleValidationViewModel

    var body: some View {
        GeometryReader { proxy in
            if proxy.size.width < 760 {
                compactLayout
            } else {
                regularLayout
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    Task { await viewModel.scan(steamRootPath: settings.steamRootPath) }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.loadState.isLoading)

                Button {
                    if let url = FilePanels.chooseFolder(message: "Choose your Steam folder") {
                        settings.steamRootPath = url.path
                        Task { await viewModel.scan(steamRootPath: settings.steamRootPath) }
                    }
                } label: {
                    Label("Choose Steam Folder", systemImage: "folder")
                }
            }
        }
    }

    private var regularLayout: some View {
        HSplitView {
            libraryPane
                .frame(minWidth: 260, idealWidth: 340)

            detailPane
                .frame(minWidth: 360)
        }
    }

    private var compactLayout: some View {
        VStack(spacing: 0) {
            libraryPane
                .frame(minHeight: 220)

            Divider()

            detailPane
                .frame(minHeight: 260)
        }
    }

    private var libraryPane: some View {
        VStack(spacing: 0) {
            libraryHeader
                .padding([.horizontal, .top])
                .padding(.bottom, 12)

            Divider()

            gameList
        }
    }

    private var detailPane: some View {
        GameDetailView(
            game: viewModel.selectedGame,
            settings: settings,
            launchPlanViewModel: launchPlanViewModel,
            bottleViewModel: bottleViewModel
        )
    }

    private var libraryHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    Text("Steam Library")
                        .font(.title2.weight(.semibold))
                    Spacer()
                    if viewModel.loadState.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Steam Library")
                        .font(.title2.weight(.semibold))
                    if viewModel.loadState.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }

            TextField("Search games", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
        }
    }

    @ViewBuilder
    private var gameList: some View {
        if let message = viewModel.loadState.errorMessage {
            EmptyStateView(
                systemImage: "exclamationmark.triangle",
                title: "Could Not Scan Steam",
                message: message
            )
        } else if viewModel.filteredGames.isEmpty {
            EmptyStateView(
                systemImage: "rectangle.stack",
                title: "No Games Found",
                message: "Refresh the library or choose a Steam folder in Settings."
            )
        } else {
            List(selection: selectedGameID) {
                ForEach(viewModel.filteredGames) { game in
                    GameListRow(game: game)
                        .tag(game.id)
                }
            }
            .listStyle(.inset)
        }
    }

    private var selectedGameID: Binding<String?> {
        Binding {
            viewModel.selectedGame?.id
        } set: { selectedID in
            guard let selectedID else {
                viewModel.selectedGame = nil
                return
            }

            viewModel.selectedGame = viewModel.filteredGames.first { $0.id == selectedID }
                ?? viewModel.games.first { $0.id == selectedID }
        }
    }
}

private struct GameListRow: View {
    let game: SteamGame

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(game.name)
                .font(.body)
                .lineLimit(1)
            HStack(spacing: 8) {
                Text("App ID \(game.appID)")
                Text(game.isInstalled ? game.installDirectoryName : "Not installed")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(1)

            if !game.isInstalled {
                Label("Local Steam library entry", systemImage: "icloud.and.arrow.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}