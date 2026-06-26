import Foundation
import WinmacCore

@MainActor
public final class BottleValidationViewModel: ObservableObject {
    private let service: BottleValidating

    @Published public var prefixPath = ""
    @Published public private(set) var validation: BottleValidation?
    @Published public private(set) var loadState: LoadState = .idle

    public init(service: BottleValidating = BottleService()) {
        self.service = service
    }

    public var status: ValidationStatus {
        guard let validation else { return .notChecked }
        return validation.isValid ? .valid : .invalid
    }

    public func validate() async {
        guard let prefixURL = Self.url(from: prefixPath) else {
            loadState = .failed("Choose a Wine prefix folder first.")
            validation = nil
            return
        }

        loadState = .loading
        validation = await service.validateBottle(prefixURL: prefixURL)
        loadState = .idle
    }

    public func updatePath(_ url: URL) {
        prefixPath = url.standardizedFileURL.path
    }

    private static func url(from path: String) -> URL? {
        let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPath.isEmpty else { return nil }
        return URL(fileURLWithPath: NSString(string: trimmedPath).expandingTildeInPath).standardizedFileURL
    }
}