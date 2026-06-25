import XCTest
@testable import WinmacCore

final class LaunchPlannerTests: XCTestCase {
    func testMergesLaunchProfilesInOrder() {
        let planner = LaunchPlanner()
        let runtimeDefaults = LaunchProfile(environment: ["DXVK_HUD": "0", "A": "runtime"])
        let gameProfile = LaunchProfile(environment: ["A": "game"], dllOverrides: ["dinput8": "native,builtin"])
        let userOverrides = LaunchProfile(environment: ["DXVK_HUD": "fps"], arguments: ["-novid"])

        let merged = planner.mergedProfile([runtimeDefaults, gameProfile, userOverrides])

        XCTAssertEqual(merged.environment["A"], "game")
        XCTAssertEqual(merged.environment["DXVK_HUD"], "fps")
        XCTAssertEqual(merged.environment["WINEDLLOVERRIDES"], "dinput8=native,builtin")
        XCTAssertEqual(merged.arguments, ["-novid"])
    }

    func testBuildsLaunchPlanWithoutValidationForDryRun() throws {
        let plan = try LaunchPlanner().makePlan(
            executableURL: URL(fileURLWithPath: "/Games/Fake/game.exe"),
            prefixURL: URL(fileURLWithPath: "/Prefixes/Fake"),
            validateInputs: false
        )

        XCTAssertEqual(plan.environment["WINEARCH"], "win64")
        XCTAssertEqual(plan.environment["WINEPREFIX"], "/Prefixes/Fake")
        XCTAssertEqual(plan.environment["WINEDLLOVERRIDES"], "winemenubuilder.exe=d")
    }

    func testBuildsDLLOverridesDeterministicallyWithDefaults() throws {
        let plan = try LaunchPlanner().makePlan(
            executableURL: URL(fileURLWithPath: "/Games/Fake/game.exe"),
            prefixURL: URL(fileURLWithPath: "/Prefixes/Fake"),
            profiles: [
                .winmacDefaults,
                LaunchProfile(dllOverrides: ["dinput8": "native,builtin"])
            ],
            validateInputs: false
        )

        XCTAssertEqual(plan.environment["WINEDLLOVERRIDES"], "dinput8=native,builtin;winemenubuilder.exe=d")
    }
}