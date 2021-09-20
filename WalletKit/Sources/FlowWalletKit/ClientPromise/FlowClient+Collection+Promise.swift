import Foundation
import PromiseKit

extension FlowClient {
    public func getCollectionById(_ id: FlowIdentifier) -> Promise<FlowCollection> {
        return Promise<FlowCollection> { task in
            self.getCollectionById(id: id) {
                response in
                guard let account = response.result as? FlowCollection else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(account)
            }
        }
    }
}
