import SwiftUI
import WinmacAppSupport
import WinmacCore

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

struct InlineMessage: View {
    let systemImage: String
    let text: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.callout)
            .foregroundColor(.secondary)
            .textSelection(.enabled)
    }
}

struct StatusBadge: View {
    let status: ValidationStatus

    var body: some View {
        Label(status.title, systemImage: imageName)
            .font(.caption.weight(.medium))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private var imageName: String {
        switch status {
        case .notChecked:
            return "circle"
        case .valid:
            return "checkmark.circle"
        case .invalid:
            return "xmark.circle"
        }
    }

    private var color: Color {
        switch status {
        case .notChecked:
            return .secondary
        case .valid:
            return .green
        case .invalid:
            return .red
        }
    }
}

struct PathGridRow: View {
    let label: String
    let value: String

    var body: some View {
        GridRow {
            Text(label)
                .foregroundColor(.secondary)
            Text(value.isEmpty ? "Not set" : value)
                .lineLimit(3)
                .truncationMode(.middle)
                .textSelection(.enabled)
        }
    }
}

struct BottleValidationSummary: View {
    let validation: BottleValidation?

    var body: some View {
        if let validation {
            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                PathGridRow(label: "Path", value: validation.path)
                PathGridRow(label: "Architecture", value: validation.architecture.rawValue)
                PathGridRow(label: "drive_c", value: validation.hasDriveC ? "Present" : "Missing")
                PathGridRow(label: "user.reg", value: validation.hasUserRegistry ? "Present" : "Missing")
                PathGridRow(label: "system.reg", value: validation.hasSystemRegistry ? "Present" : "Missing")
                PathGridRow(label: "Writable", value: validation.isWritable ? "Yes" : "No")
                PathGridRow(label: "Broken Symlinks", value: "\(validation.brokenSymlinks.count)")
            }

            if !validation.brokenSymlinks.isEmpty {
                DisclosureGroup("Broken Symlinks") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(validation.brokenSymlinks, id: \.self) { path in
                            Text(path)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                        }
                    }
                    .padding(.top, 6)
                }
            }
        } else {
            Text("No bottle has been validated yet.")
                .foregroundColor(.secondary)
        }
    }
}

struct LaunchPlanSummary: View {
    let launchPlan: LaunchPlan
    let showRawJSON: Bool
    let json: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                PathGridRow(label: "Executable", value: launchPlan.executablePath)
                PathGridRow(label: "Prefix", value: launchPlan.prefixPath)
                PathGridRow(label: "Working Directory", value: launchPlan.workingDirectory)
                PathGridRow(label: "Arguments", value: launchPlan.arguments.isEmpty ? "None" : launchPlan.arguments.joined(separator: " "))
            }

            DisclosureGroup("Environment") {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(launchPlan.environment.keys.sorted(), id: \.self) { key in
                        Text("\(key)=\(launchPlan.environment[key] ?? "")")
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
                .padding(.top, 6)
            }

            if showRawJSON {
                DisclosureGroup("Raw JSON") {
                    JSONPreview(text: json)
                        .frame(minHeight: 180)
                }
            }
        }
    }
}

struct JSONPreview: View {
    let text: String

    var body: some View {
        ScrollView {
            Text(text.isEmpty ? "No JSON to show." : text)
                .font(.system(.caption, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .textSelection(.enabled)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

extension LoadState {
    var isLoading: Bool { self == .loading }

    var errorMessage: String? {
        guard case .failed(let message) = self else { return nil }
        return message
    }
}