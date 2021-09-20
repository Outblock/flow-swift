import Flow
import Foundation
import GRPC
import Swift
import SwiftProtobuf

public class RpcResponse<T: FlowEntity> {
    public var error: Error?
    public var result: T?

    public init(result: T?, error: Error?) {
        self.result = result
        self.error = error
    }
}

public typealias ResultCallback = (RpcResponse<FlowEntity>) -> Void

public protocol FlowRpcClientProtocol {
    func getAccount(account: FlowAddress, completion: @escaping (ResultCallback))
    func getAccountAtLatestBlock(account: FlowAddress, completion: @escaping (ResultCallback))
    func getAccountAtBlockHeight(account: FlowAddress, height: Int, completion: @escaping (ResultCallback))
    func ping(completion: @escaping (ResultCallback))
    func getLatestBlock(isSealed: Bool, completion: @escaping (ResultCallback))
    func getLatestBlockHeader(isSealed: Bool, completion: @escaping (ResultCallback))
    func getBlockHeaderById(id: FlowIdentifier, completion: @escaping (ResultCallback))
    func getBlockHeaderByHeight(height: Int, completion: @escaping (ResultCallback))
    func getBlockById(id: FlowIdentifier, completion: @escaping (ResultCallback))
    func getBlockByHeight(height: Int, completion: @escaping (ResultCallback))
    func getExecutionResultForBlockId(id: FlowIdentifier, completion: @escaping (ResultCallback))
    func getCollectionById(id: FlowIdentifier, completion: @escaping (ResultCallback))
    func getEventsForHeightRange(type: String, start: Int, end: Int, completion: @escaping (ResultCallback))
    func getEventsForBlockIds(type: String, blockIds: [FlowIdentifier], completion: @escaping (ResultCallback))
    func executeScriptAtLatestBlock(script: String, arguments: [CadenceValue], completion: @escaping (ResultCallback))
    func executeScriptAtBlockId(script: String, blockId: FlowIdentifier, arguments: [CadenceValue], completion: @escaping (ResultCallback))
    func executeScriptAtBlockHeight(script: String, height: Int, arguments: [CadenceValue], completion: @escaping (ResultCallback))
    func getNetworkParameters(completion: @escaping (ResultCallback))
    func getLatestProtocolStateSnapshot(completion: @escaping (ResultCallback))
    func sendTransaction(transaction: FlowTransaction, completion: @escaping (ResultCallback))
    func getTransactionResult(id: FlowIdentifier, completion: @escaping (ResultCallback))
}
