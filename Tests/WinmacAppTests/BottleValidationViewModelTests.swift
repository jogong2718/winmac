import Foundation
import XCTest
@testable import WinmacAppSupport
import WinmacCore

@MainActor
final class BottleValidationViewModelTests: XCTestCase {
    func testValidateUpdatesStatus() async {
        let validation = BottleValidation(
            path: "/prefix",
            exists: true,
            hasDriveC: true,
            hasUserRegistry: true,
            hasSystemRegistry: true,
            architecture: .win64,
            isWritable: true,
            brokenSymlinks: []
        )
        let viewModel = BottleValidationViewModel(service: MockBottleService(validation: validation))
        viewModel.prefixPath = "/prefix"

        await viewModel.validate()

        XCTAssertEqual(viewModel.validation, validation)
        XCTAssertEqual(viewModel.status, .valid)
        XCTAssertEqual(viewModel.loadState, .idle)
    }

    func testValidateRequiresPath() async {
        let viewModel = BottleValidationViewModel(service: MockBottleService(validation: nil))

        await viewModel.validate()

        XCTAssertEqual(viewModel.status, .notChecked)
        XCTAssertEqual(viewModel.loadState, .failed("Choose a Wine prefix folder first."))
    }
}

private struct MockBottleService: BottleValidating {
    let validation: BottleValidation?

    func validateBottle(prefixURL: URL) async -> BottleValidation {
        validation ?? BottleValidation(
            path: prefixURL.path,
            exists: false,
            hasDriveC: false,
            hasUserRegistry: false,
            hasSystemRegistry: false,
            architecture: .unknown,
            isWritable: false,
            brokenSymlinks: []
        )
    }
}