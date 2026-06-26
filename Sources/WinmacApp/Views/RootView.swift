import SwiftUI
import WinmacAppSupport

struct RootView: View {
    @ObservedObject var settings: UserSettings
    @ObservedObject var libraryViewModel: LibraryViewModel
    @ObservedObject var bottleViewModel: BottleValidationViewModel
    @ObservedObject var launchPlanViewModel: LaunchPlanViewModel
    @ObservedObject var diagnosticsViewModel: DiagnosticsViewModel

    @State private var selectedSection: AppSection? = .library

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSection) {
                Section("Winmac") {
                    ForEach(AppSection.allCases) { section in
                        Label(section.title, systemImage: section.systemImage)
                            .tag(Optional(section))
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Winmac")
            .navigationSplitViewColumnWidth(min: 150, ideal: 180, max: 220)
        } detail: {
            content
                .navigationTitle((selectedSection ?? .library).title)
        }
        .navigationSplitViewStyle(.balanced)
        .task {
            if libraryViewModel.games.isEmpty {
                await libraryViewModel.scan(steamRootPath: settings.steamRootPath)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedSection ?? .library {
        case .library:
            LibraryView(
                settings: settings,
                viewModel: libraryViewModel,
                launchPlanViewModel: launchPlanViewModel,
                bottleViewModel: bottleViewModel
            )
        case .bottles:
            BottlesView(viewModel: bottleViewModel)
        case .launchPlan:
            LaunchPlanView(settings: settings, viewModel: launchPlanViewModel)
        case .diagnostics:
            DiagnosticsView(viewModel: diagnosticsViewModel)
        }
    }
}