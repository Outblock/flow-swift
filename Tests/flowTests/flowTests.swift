@testable import Flow
import XCTest

final class flowTests: XCTestCase {
    func testFlowInit() {
        XCTAssertEqual(Flow().text, "Hello, World!")
    }
}
