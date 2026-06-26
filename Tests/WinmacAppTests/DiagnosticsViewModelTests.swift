import Foundation
import XCTest
@testable import WinmacAppSupport
import WinmacCore

@MainActor
final class DiagnosticsViewModelTests: XCTestCase {
    func testGenerateStoresReport() async {
        let report = DiagnosticReport(
            generatedAt: Date(timeIntervalSince1970: 0),
            appVersion: "test",
            host: HostSummary(operatingSystem: "macOS", architecture: "arm64", homeDirectoryRedacted: "~"),
            notes: ["note"]
        )
        let viewModel = DiagnosticsViewModel(service: MockDiagnosticsService(report: report))

        await viewModel.generate()

        XCTAssertEqual(viewModel.report, report)
        XCTAssertEqual(viewModel.loadState, .idle)
        XCTAssertTrue(viewModel.reportJSON.contains("macOS"))
    }
}

private struct MockDiagnosticsService: DiagnosticsProviding {
    let report: DiagnosticReport

    func makeReport(notes: [String]) async -> DiagnosticReport {
        report
    }

    func export(report: DiagnosticReport, to outputURL: URL) async throws {}
}