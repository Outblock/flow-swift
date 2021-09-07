@testable import Flow
import XCTest

final class CadenceTypeTests: XCTestCase {
    func testIntType() throws {
        let jsonString = """
        {
           "type":"Int",
           "value":"1"
        }
        """

        let result = try! JSONDecoder().decode(Flow.Argument.self, from: jsonString.data(using: .utf8)!)

        func getGeneric<T>(object _: T) -> T.Type {
            return T.self
        }

        print(getGeneric(object: result.value))
        print(type(of: result.value))
        print(result)
    }
}
