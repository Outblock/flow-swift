@testable import Flow
import XCTest

final class FlowAPITests: XCTestCase {
    var flowAPI: FlowAPI!

    override func setUp() {
        super.setUp()
        Flow.shared.config.put(key: Flow.Constants.wallet,
                               value: "https://29729fab-f834-4126-90c4-a4c2f9844c9d.mock.pstmn.io")
        flowAPI = FlowAPI()
    }

    func testAuthn() throws {
        let result = try flowAPI.authn().wait()
        XCTAssertNotNil(result)
    }
}
