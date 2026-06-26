import SwiftUI
import WinmacAppSupport

struct DiagnosticsView: View {
    @ObservedObject var viewModel: DiagnosticsViewModel

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Report") {
                    HStack {
                        Button {
                            Task { await viewModel.generate() }
                        } label: {
                            Label("Generate", systemImage: "stethoscope")
                        }
                        .disabled(viewModel.loadState.isLoading)

                        Button {
                            if let url = FilePanels.saveJSON(message: "Export diagnostics", defaultName: "winmac-diagnostics.json") {
                                Task { await viewModel.export(to: url) }
                            }
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.down")
                        }
                        .disabled(viewModel.loadState.isLoading)

                        if viewModel.loadState.isLoading {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }

                    if let lastExportPath = viewModel.lastExportPath {
                        LabeledContent("Last Export") {
                            Text(lastExportPath)
                                .textSelection(.enabled)
                        }
                    }

                    Text("Diagnostics are intentionally small for this phase. Runtime, launch, and log details arrive with Wine execution.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }

                if let message = viewModel.loadState.errorMessage {
                    Section("Issue") {
                        InlineMessage(systemImage: "exclamationmark.triangle", text: message)
                    }
                }
            }
            .formStyle(.grouped)

            Divider()

            JSONPreview(text: viewModel.reportJSON)
                .padding()
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    Task { await viewModel.generate() }
                } label: {
                    Label("Generate", systemImage: "stethoscope")
                }
                .disabled(viewModel.loadState.isLoading)

                Button {
                    if let url = FilePanels.saveJSON(message: "Export diagnostics", defaultName: "winmac-diagnostics.json") {
                        Task { await viewModel.export(to: url) }
                    }
                } label: {
                    Label("Export", systemImage: "square.and.arrow.down")
                }
                .disabled(viewModel.loadState.isLoading)
            }
        }
        .task {
            if viewModel.report == nil {
                await viewModel.generate()
            }
        }
    }
}