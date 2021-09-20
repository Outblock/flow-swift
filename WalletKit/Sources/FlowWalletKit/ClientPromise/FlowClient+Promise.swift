import Foundation
import PromiseKit

extension FlowClient {
    public func ping() -> Promise<FlowEntity> {
        return Promise<FlowEntity> { task in
            self.rpcProvider.ping() {
                response in
                guard let result = response.result else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(result)
            }
        }
    }
}
