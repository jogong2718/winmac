import AppKit
import SwiftUI
import WinmacAppSupport

struct BottlesView: View {
    @ObservedObject var viewModel: BottleValidationViewModel

    var body: some View {
        Form {
            Section("Prefix") {
                ViewThatFits(in: .horizontal) {
                    prefixPickerRow
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Wine prefix folder", text: $viewModel.prefixPath)
                            .textFieldStyle(.roundedBorder)
                        choosePrefixButton
                    }
                }

                ViewThatFits(in: .horizontal) {
                    HStack {
                        StatusBadge(status: viewModel.status)
                        Spacer()
                        validateButton
                        loadingIndicator
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        StatusBadge(status: viewModel.status)
                        HStack {
                            validateButton
                            loadingIndicator
                        }
                    }
                }

                if let message = viewModel.loadState.errorMessage {
                    InlineMessage(systemImage: "exclamationmark.triangle", text: message)
                }
            }

            Section("Result") {
                BottleValidationSummary(validation: viewModel.validation)

                if let validation = viewModel.validation {
                    Button {
                        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: validation.path)])
                    } label: {
                        Label("Reveal in Finder", systemImage: "folder")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding(.top, 8)
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
                viewModel.updatePath(url)
            }
        } label: {
            Label("Choose", systemImage: "folder")
        }
    }

    private var validateButton: some View {
        Button {
            Task { await viewModel.validate() }
        } label: {
            Label("Validate", systemImage: "checkmark.seal")
        }
        .keyboardShortcut(.return, modifiers: .command)
        .disabled(viewModel.loadState.isLoading)
    }

    @ViewBuilder
    private var loadingIndicator: some View {
        if viewModel.loadState.isLoading {
            ProgressView()
                .controlSize(.small)
        }
    }
}