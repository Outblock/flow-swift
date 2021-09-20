import Foundation
import PromiseKit

extension FlowClient {
    public func getAccount(_ address: FlowAddress) -> Promise<FlowAccount> {
        return Promise<FlowAccount> { task in
            self.rpcProvider.getAccount(account: address) {
                response in
                guard let account = response.result as? FlowAccount else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(account)
            }
        }
    }

    public func getAccountAtLatestBlock(_ address: FlowAddress) -> Promise<FlowAccount> {
        return Promise<FlowAccount> { task in
            self.rpcProvider.getAccountAtLatestBlock(account: address) {
                response in
                guard let account = response.result as? FlowAccount else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(account)
            }
        }
    }

    public func getAccountAtBlockHeight(_ address: FlowAddress, height: Int) -> Promise<FlowAccount> {
        return Promise<FlowAccount> { task in
            self.rpcProvider.getAccountAtBlockHeight(account: address, height: height) {
                response in
                guard let account = response.result as? FlowAccount else {
                    task.reject(response.error!)
                    return
                }
                task.fulfill(account)
            }
        }
    }
}
