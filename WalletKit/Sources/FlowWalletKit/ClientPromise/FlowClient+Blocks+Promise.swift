import Foundation
import PromiseKit

extension FlowClient {
    public func getLatestBlockHeader(isSealed: Bool) -> Promise<FlowBlockHeader> {
        return Promise<FlowBlockHeader> { task in
            self.rpcProvider.getLatestBlockHeader(isSealed: isSealed) {
                response in
                guard let result = response.result as? FlowBlockHeader else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(result)
            }
        }
    }

    public func getLatestBlock(isSealed: Bool) -> Promise<FlowBlock> {
        return Promise<FlowBlock> { task in
            self.rpcProvider.getLatestBlock(isSealed: isSealed) {
                response in
                guard let result = response.result as? FlowBlock else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(result)
            }
        }
    }

    public func getBlockHeaderById(id: FlowIdentifier) -> Promise<FlowBlockHeader> {
        return Promise<FlowBlockHeader> { task in
            self.getBlockHeaderById(id: id) {
                response in
                guard let result = response.result as? FlowBlockHeader else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(result)
            }
        }
    }

    public func getBlockById(id: FlowIdentifier) -> Promise<FlowBlock> {
        return Promise<FlowBlock> { task in
            self.getBlockById(id: id) {
                response in
                guard let result = response.result as? FlowBlock else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(result)
            }
        }
    }

    public func getBlockHeaderByHeight(height: Int) -> Promise<FlowBlockHeader> {
        return Promise<FlowBlockHeader> { task in
            self.rpcProvider.getBlockHeaderByHeight(height: height) {
                response in
                guard let result = response.result as? FlowBlockHeader else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(result)
            }
        }
    }

    public func getBlockByHeight(height: Int) -> Promise<FlowBlock> {
        return Promise<FlowBlock> { task in
            self.rpcProvider.getBlockByHeight(height: height) {
                response in
                guard let result = response.result as? FlowBlock else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(result)
            }
        }
    }

    public func getExecutionResultForBlockID(id: FlowIdentifier) -> Promise<FlowExecutionResult> {
        return Promise<FlowExecutionResult> { task in
            self.getExecutionResultForBlockID(id: id) {
                response in
                guard let result = response.result as? FlowExecutionResult else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(result)
            }
        }
    }
}
