import SwiftUI
import WinmacAppSupport

struct LaunchPlanView: View {
    @ObservedObject var settings: UserSettings
    @ObservedObject var viewModel: LaunchPlanViewModel

    var body: some View {
        Form {
            Section("Inputs") {
                ViewThatFits(in: .horizontal) {
                    executablePickerRow
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Windows executable", text: $viewModel.executablePath)
                            .textFieldStyle(.roundedBorder)
                        chooseExecutableButton
                    }
                }

                ViewThatFits(in: .horizontal) {
                    prefixPickerRow
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Wine prefix folder", text: $viewModel.prefixPath)
                            .textFieldStyle(.roundedBorder)
                        choosePrefixButton
                    }
                }

                Toggle("Validate executable and prefix before building", isOn: $viewModel.validateInputs)
            }

            Section {
                HStack {
                    Button {
                        Task { await viewModel.buildPlan() }
                    } label: {
                        Label("Build Plan", systemImage: "doc.text.magnifyingglass")
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(viewModel.loadState.isLoading)

                    if viewModel.loadState.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }

                    Spacer()

                    Text("Preview only")
                        .foregroundColor(.secondary)
                }
            }

            if let message = viewModel.loadState.errorMessage {
                Section("Issue") {
                    InlineMessage(systemImage: "exclamationmark.triangle", text: message)
                }
            }

            Section("Preview") {
                if let launchPlan = viewModel.launchPlan {
                    LaunchPlanSummary(
                        launchPlan: launchPlan,
                        showRawJSON: true,
                        json: viewModel.launchPlanJSON
                    )
                } else {
                    Text("Build a launch plan to inspect environment variables, arguments, and working directory.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding(.top, 8)
        .toolbar {
            ToolbarItem {
                Button {
                    Task { await viewModel.buildPlan() }
                } label: {
                    Label("Build Plan", systemImage: "doc.text.magnifyingglass")
                }
                .disabled(viewModel.loadState.isLoading)
            }
        }
    }

    private var executablePickerRow: some View {
        HStack {
            TextField("Windows executable", text: $viewModel.executablePath)
                .textFieldStyle(.roundedBorder)
            chooseExecutableButton
        }
    }

    private var chooseExecutableButton: some View {
        Button {
            if let url = FilePanels.chooseFile(message: "Choose a Windows executable") {
                viewModel.useExecutable(url)
            }
        } label: {
            Label("Choose", systemImage: "doc")
        }
    }

    private var prefixPickerRow: some View {
        HStack {
            TextField("Wine prefix folder", text: $viewModel.prefixPath)
                .textFieldStyle(.roundedBorder)
            choosePrefixButton
        }
    }

    private var choosePrefixButton: some View {
        Button {
            if let url = FilePanels.chooseFolder(message: "Choose a Wine prefix") {
                viewModel.usePrefix(url)
            }
        } label: {
            Label("Choose", systemImage: "folder")
        }
    }
}