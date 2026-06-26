import Foundation
import XCTest
@testable import WinmacAppSupport
import WinmacCore

@MainActor
final class LaunchPlanViewModelTests: XCTestCase {
    func testBuildPlanStoresLaunchPlan() async {
        let plan = LaunchPlan(
            executablePath: "/game.exe",
            prefixPath: "/prefix",
            workingDirectory: "/",
            environment: ["WINEARCH": "win64"],
            arguments: []
        )
        let viewModel = LaunchPlanViewModel(service: MockLaunchPlanService(result: .success(plan)))
        viewModel.executablePath = "/game.exe"
        viewModel.prefixPath = "/prefix"

        await viewModel.buildPlan()

        XCTAssertEqual(viewModel.launchPlan, plan)
        XCTAssertEqual(viewModel.loadState, .idle)
        XCTAssertTrue(viewModel.launchPlanJSON.contains("WINEARCH"))
    }

    func testBuildPlanRequiresExecutable() async {
        let viewModel = LaunchPlanViewModel(service: MockLaunchPlanService(result: .failure(MockError.failure)))
        viewModel.prefixPath = "/prefix"

        await viewModel.buildPlan()

        XCTAssertNil(viewModel.launchPlan)
        XCTAssertEqual(viewModel.loadState, .failed("Choose a Windows executable first."))
    }
}

private struct MockLaunchPlanService: LaunchPlanBuilding {
    let result: Result<LaunchPlan, Error>

    func makePlan(executableURL: URL, prefixURL: URL, validateInputs: Bool) async throws -> LaunchPlan {
        try result.get()
    }
}

private enum MockError: Error {
    case failure
}