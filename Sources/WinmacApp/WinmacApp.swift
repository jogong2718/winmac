import SwiftUI
import WinmacAppSupport

@main
struct WinmacApp: App {
    @StateObject private var settings = UserSettings()
    @StateObject private var libraryViewModel = LibraryViewModel()
    @StateObject private var bottleViewModel = BottleValidationViewModel()
    @StateObject private var launchPlanViewModel = LaunchPlanViewModel()
    @StateObject private var diagnosticsViewModel = DiagnosticsViewModel()

    var body: some Scene {
        WindowGroup("Winmac") {
            RootView(
                settings: settings,
                libraryViewModel: libraryViewModel,
                bottleViewModel: bottleViewModel,
                launchPlanViewModel: launchPlanViewModel,
                diagnosticsViewModel: diagnosticsViewModel
            )
            .frame(minWidth: 720, minHeight: 520)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Refresh Library") {
                    Task { await libraryViewModel.scan(steamRootPath: settings.steamRootPath) }
                }
                .keyboardShortcut("r", modifiers: [.command])

                Button("Generate Diagnostics") {
                    Task { await diagnosticsViewModel.generate() }
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView(settings: settings)
                .frame(width: 560)
                .padding()
        }
    }
}