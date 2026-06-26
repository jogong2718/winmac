import Foundation

public enum AppSection: String, CaseIterable, Identifiable {
    case library
    case bottles
    case launchPlan
    case diagnostics

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .library:
            return "Library"
        case .bottles:
            return "Bottles"
        case .launchPlan:
            return "Launch Plan"
        case .diagnostics:
            return "Diagnostics"
        }
    }

    public var systemImage: String {
        switch self {
        case .library:
            return "rectangle.stack"
        case .bottles:
            return "shippingbox"
        case .launchPlan:
            return "terminal"
        case .diagnostics:
            return "stethoscope"
        }
    }
}

public enum LoadState: Equatable {
    case idle
    case loading
    case failed(String)
}

public enum ValidationStatus: Equatable {
    case notChecked
    case valid
    case invalid

    public var title: String {
        switch self {
        case .notChecked:
            return "Not Checked"
        case .valid:
            return "Valid"
        case .invalid:
            return "Invalid"
        }
    }
}