import XCTest
@testable import Macchiato

final class CaffeinateServiceTests: XCTestCase {

    func testStartActivatesCaffeinate() {
        let service = CaffeinateService()
        defer { service.stop() }

        service.start()

        XCTAssertTrue(service.isActive)
    }

    func testStopDeactivatesCaffeinate() {
        let service = CaffeinateService()

        service.start()
        service.stop()

        XCTAssertFalse(service.isActive)
    }

    func testStartWhileActiveIsNoOp() {
        let service = CaffeinateService()
        defer { service.stop() }

        service.start()
        service.start()

        XCTAssertTrue(service.isActive)
    }

    func testStopWhileInactiveIsNoOp() {
        let service = CaffeinateService()

        service.stop()

        XCTAssertFalse(service.isActive)
    }

    func testToggleStartsThenStops() {
        let service = CaffeinateService()

        service.toggle()
        XCTAssertTrue(service.isActive)

        service.toggle()
        XCTAssertFalse(service.isActive)
    }
}
