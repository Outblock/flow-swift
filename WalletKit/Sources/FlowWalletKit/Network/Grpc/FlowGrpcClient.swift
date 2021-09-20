import Flow
import Foundation

public class FlowGrpcClient: FlowRpcClientProtocol {
    var transport: GRPCTransport

    public init(host: String, port: Int) {
        transport = GRPCTransport(host: host, port: port)
    }

    public func getTransactionResult(id: FlowIdentifier, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetTransactionRequest, Flow_Access_TransactionResultResponse>
            .with(transport.client.getTransactionResult,
                  transform: {
                      $0.id = Data(id)
                  }, success: {
                      FlowTransactionResult.from($0) as! FlowTransactionResult
                  },
                  completion: completion)
    }

    public func sendTransaction(transaction: FlowTransaction, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_SendTransactionRequest, Flow_Access_SendTransactionResponse>
            .with(transport.client.sendTransaction,
                  transform: {
                      var tosend = Flow_Entities_Transaction()
                      tosend.script = transaction.script.data(using: .utf8)!
                      tosend.arguments = transaction.arguments.map { arg in arg.toJSON()! }
                      tosend.referenceBlockID = transaction.referenceBlockId.data
                      tosend.gasLimit = UInt64(transaction.gasLimit)
                      tosend.proposalKey.address = transaction.proposalKey.address.data
                      tosend.proposalKey.keyID = UInt32(transaction.proposalKey.keyId)
                      tosend.proposalKey.sequenceNumber = UInt64(transaction.proposalKey.sequenceNumber)
                      tosend.payer = transaction.payer.data
                      tosend.authorizers = transaction.authorizers.map { auth in auth.data }

                      for signature in transaction.payloadSignatures {
                          var s = Flow_Entities_Transaction.Signature()
                          s.address = signature.address.data
                          s.keyID = UInt32(signature.keyId)
                          s.signature = signature.signature.data
                          tosend.payloadSignatures.append(s)
                      }

                      for signature in transaction.envelopeSignatures {
                          var s = Flow_Entities_Transaction.Signature()
                          s.address = signature.address.data
                          s.keyID = UInt32(signature.keyId)
                          s.signature = signature.signature.data
                          tosend.envelopeSignatures.append(s)
                      }

                      $0.transaction = tosend

                  },
                  success: {
                      FlowIdentifier.from($0.id)
                  },
                  completion: completion)
    }

    public func getAccount(account: FlowAddress, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetAccountRequest, Flow_Access_GetAccountResponse>
            .with(transport.client.getAccount,
                  transform: {
                      $0.address = account.data
                  },
                  success: {
                      FlowAccount.from($0.account) as? FlowAccount
                  },
                  completion: completion)
    }

    public func getAccountAtLatestBlock(account: FlowAddress, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetAccountAtLatestBlockRequest, Flow_Access_AccountResponse>
            .with(transport.client.getAccountAtLatestBlock,
                  transform: {
                      $0.address = account.data
                  },
                  success: {
                      FlowAccount.from($0.account) as? FlowAccount
                  },
                  completion: completion)
    }

    public func getAccountAtBlockHeight(account: FlowAddress, height: Int, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetAccountAtBlockHeightRequest, Flow_Access_AccountResponse>
            .with(transport.client.getAccountAtBlockHeight,
                  transform: {
                      $0.address = account.data
                      $0.blockHeight = UInt64(height)
                  },
                  success: {
                      FlowAccount.from($0.account) as? FlowAccount
                  },
                  completion: completion)
    }

    public func ping(completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_PingRequest, Flow_Access_PingResponse>
            .with(transport.client.ping,
                  transform: { _ in
                  },
                  success: { _ in
                      FlowEntity()
                  },
                  completion: completion)
    }

    public func getLatestBlock(isSealed _: Bool, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetLatestBlockRequest, Flow_Access_BlockResponse>
            .with(transport.client.getLatestBlock,
                  transform: { _ in
                  },
                  success: {
                      FlowBlock.from($0.block)
                  },
                  completion: completion)
    }

    public func getLatestBlockHeader(isSealed _: Bool, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetLatestBlockHeaderRequest, Flow_Access_BlockHeaderResponse>
            .with(transport.client.getLatestBlockHeader,
                  transform: { _ in
                  },
                  success: {
                      FlowBlockHeader.from($0.block)
                  },
                  completion: completion)
    }

    public func getBlockHeaderById(id: FlowIdentifier, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetBlockHeaderByIDRequest, Flow_Access_BlockHeaderResponse>
            .with(transport.client.getBlockHeaderByID,
                  transform: {
                      $0.id = Data(id)
                  },
                  success: {
                      FlowBlockHeader.from($0.block)
                  },
                  completion: completion)
    }

    public func getBlockHeaderByHeight(height: Int, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetBlockHeaderByHeightRequest, Flow_Access_BlockHeaderResponse>
            .with(transport.client.getBlockHeaderByHeight,
                  transform: {
                      $0.height = UInt64(height)
                  },
                  success: {
                      FlowBlockHeader.from($0.block)
                  },
                  completion: completion)
    }

    public func getBlockById(id: FlowIdentifier, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetBlockByIDRequest, Flow_Access_BlockResponse>
            .with(transport.client.getBlockByID,
                  transform: {
                      $0.id = Data(id)
                  },
                  success: {
                      FlowBlock.from($0.block)
                  },
                  completion: completion)
    }

    public func getBlockByHeight(height: Int, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetBlockByHeightRequest, Flow_Access_BlockResponse>
            .with(transport.client.getBlockByHeight,
                  transform: {
                      $0.height = UInt64(height)
                  },
                  success: {
                      FlowBlock.from($0.block)
                  },
                  completion: completion)
    }

    public func getExecutionResultForBlockId(id: FlowIdentifier, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetExecutionResultForBlockIDRequest, Flow_Access_ExecutionResultForBlockIDResponse>
            .with(transport.client.getExecutionResultForBlockID,
                  transform: {
                      $0.blockID = Data(id)
                  },
                  success: {
                      FlowExecutionResult.from($0.executionResult)
                  },
                  completion: completion)
    }

    public func getCollectionById(id: FlowIdentifier, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetCollectionByIDRequest, Flow_Access_CollectionResponse>
            .with(transport.client.getCollectionByID,
                  transform: {
                      $0.id = Data(id)
                  },
                  success: {
                      FlowCollection.from($0.collection)
                  },
                  completion: completion)
    }

    public func getEventsForHeightRange(type: String, start: Int, end: Int, completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetEventsForHeightRangeRequest, Flow_Access_EventsResponse>
            .with(transport.client.getEventsForHeightRange,
                  transform: {
                      $0.type = type
                      $0.startHeight = UInt64(start)
                      $0.endHeight = UInt64(end)
                  },
                  success: {
                      FlowEventsResponse.from($0)
                  },
                  completion: completion)
    }

    public func getEventsForBlockIds(type: String, blockIds: [FlowIdentifier], completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetEventsForBlockIDsRequest, Flow_Access_EventsResponse>
            .with(transport.client.getEventsForBlockIDs,
                  transform: {
                      $0.type = type
                      $0.blockIds = blockIds.map { Data($0) }
                  },
                  success: {
                      FlowEventsResponse.from($0)
                  },
                  completion: completion)
    }

    public func executeScriptAtLatestBlock(script: String, arguments: [CadenceValue], completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_ExecuteScriptAtLatestBlockRequest, Flow_Access_ExecuteScriptResponse>
            .with(transport.client.executeScriptAtLatestBlock,
                  transform: {
                      $0.script = script.data(using: .utf8)!
                      $0.arguments = arguments.map { $0.toJSON()! }
                  },
                  success: {
                      CadenceValue.fromJSON($0.value)
                  },
                  completion: completion)
    }

    public func executeScriptAtBlockId(script: String, blockId: FlowIdentifier, arguments: [CadenceValue], completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_ExecuteScriptAtBlockIDRequest, Flow_Access_ExecuteScriptResponse>
            .with(transport.client.executeScriptAtBlockID,
                  transform: {
                      $0.script = script.data(using: .utf8)!
                      $0.arguments = arguments.map { $0.toJSON()! }
                      $0.blockID = Data(blockId)
                  },
                  success: {
                      CadenceValue.fromJSON($0.value)
                  },
                  completion: completion)
    }

    public func executeScriptAtBlockHeight(script: String, height: Int, arguments: [CadenceValue], completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_ExecuteScriptAtBlockHeightRequest, Flow_Access_ExecuteScriptResponse>
            .with(transport.client.executeScriptAtBlockHeight,
                  transform: {
                      $0.script = script.data(using: .utf8)!
                      $0.arguments = arguments.map { $0.toJSON()! }
                      $0.blockHeight = UInt64(height)
                  },
                  success: {
                      CadenceValue.fromJSON($0.value)
                  },
                  completion: completion)
    }

    public func getNetworkParameters(completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetNetworkParametersRequest, Flow_Access_GetNetworkParametersResponse>
            .with(transport.client.getNetworkParameters,
                  transform: { _ in
                  },
                  success: { _ in
                      FlowEntity()
                  },
                  completion: completion)
    }

    public func getLatestProtocolStateSnapshot(completion: @escaping (ResultCallback)) {
        GRPCTransport.GRPCRequest<Flow_Access_GetLatestProtocolStateSnapshotRequest, Flow_Access_ProtocolStateSnapshotResponse>
            .with(transport.client.getLatestProtocolStateSnapshot,
                  transform: { _ in
                  },
                  success: { _ in
                      FlowEntity()
                  },
                  completion: completion)
    }
}
