import Foundation
import PromiseKit

extension FlowClient {
    public func executeScriptAtLatestBlock(_ script: String, arguments: [CadenceValue] = []) -> Promise<CadenceValue> {
        return Promise<CadenceValue> { task in
            self.executeScriptAtLatestBlock(script, arguments: arguments) {
                response in
                guard let account = response.result as? CadenceValue else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(account)
            }
        }
    }

    public func executeScriptAtBlockID(_ script: String, blockId: FlowIdentifier, arguments: [CadenceValue] = []) -> Promise<CadenceValue> {
        return Promise<CadenceValue> { task in
            self.executeScriptAtBlockID(script, blockId: blockId, arguments: arguments) {
                response in
                guard let account = response.result as? CadenceValue else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(account)
            }
        }
    }

    public func executeScriptAtBlockHeight(_ script: String, height: Int, arguments: [CadenceValue] = []) -> Promise<CadenceValue> {
        return Promise<CadenceValue> { task in
            self.executeScriptAtBlockHeight(script, height: height, arguments: arguments) {
                response in
                guard let account = response.result as? CadenceValue else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(account)
            }
        }
    }
}
