@testable import flow
import XCTest

final class flowTests: XCTestCase {
    func testFlowInit() {
        XCTAssertEqual(Flow().text, "Hello, World!")
    }
}
