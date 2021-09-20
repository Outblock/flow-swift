import Foundation
import PromiseKit

extension FlowClient {
    public func getEventsForHeightRange(_ type: String, start: Int = 0, end: Int = 0) -> Promise<FlowEventsResult> {
        return Promise<FlowEventsResult> { task in
            self.getEventsForHeightRange(type: type, start: start, end: end) {
                response in
                guard let account = response.result as? FlowEventsResult else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(account)
            }
        }
    }

    public func getEventsForBlockIds(_ type: String, blockIds: [FlowIdentifier]) -> Promise<FlowEventsResult> {
        return Promise<FlowEventsResult> { task in
            self.getEventsForBlockIds(type: type, blockIds: blockIds) {
                response in
                guard let account = response.result as? FlowEventsResult else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(account)
            }
        }
    }
}
