import Foundation

extension FlowClient {
    public func getLatestBlock(isSealed: Bool = false, completion: @escaping (ResultCallback)) {
        rpcProvider.getLatestBlock(isSealed: isSealed, completion: completion)
    }

    public func getLatestBlockHeader(isSealed: Bool = false, completion: @escaping (ResultCallback)) {
        rpcProvider.getLatestBlockHeader(isSealed: isSealed, completion: completion)
    }

    public func getBlockById(id: FlowIdentifier, completion: @escaping (ResultCallback)) {
        rpcProvider.getBlockById(id: id, completion: completion)
    }

    public func getBlockHeaderById(id: FlowIdentifier, completion: @escaping (ResultCallback)) {
        rpcProvider.getBlockHeaderById(id: id, completion: completion)
    }

    public func getBlockByHeight(height: Int, completion: @escaping (ResultCallback)) {
        rpcProvider.getBlockByHeight(height: height, completion: completion)
    }

    public func getBlockHeaderByHeight(height: Int, completion: @escaping (ResultCallback)) {
        rpcProvider.getBlockHeaderByHeight(height: height, completion: completion)
    }

    public func getExecutionResultForBlockID(id: FlowIdentifier, completion: @escaping (ResultCallback)) {
        rpcProvider.getExecutionResultForBlockId(id: id, completion: completion)
    }
}
