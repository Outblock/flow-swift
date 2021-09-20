import Foundation

extension FlowClient {
    public func sendTransaction(_ transaction: FlowTransaction, completion: @escaping (ResultCallback)) {
        rpcProvider.sendTransaction(transaction: transaction, completion: completion)
    }

    public func getTransactionResult(id: FlowIdentifier, completion: @escaping (ResultCallback)) {
        rpcProvider.getTransactionResult(id: id, completion: completion)
    }

    public func sendTransaction(script: String, arguments: [CadenceValue], proposer: FlowAddress, payer: FlowAddress, authorizers _: [FlowAddress], keychain: FlowKeyChainProtocol, completion: @escaping (ResultCallback)) {
        let transaction: FlowTransaction = FlowTransaction()

        getAccount(account: proposer) {
            accountResponse in

            guard let account = accountResponse.result as? FlowAccount else {
                completion(RpcResponse(result: nil, error: FlowError.invalidAccount))
                return
            }

            guard let keychainKey = try? keychain.getKeyGroup(address: proposer).keys.first else {
                completion(RpcResponse(result: nil, error: FlowError.keyNotFound))
                return
            }

            let keys = account.keys

            transaction.proposalKey.set {
                $0.address = proposer
                $0.keyId = keychainKey.keyId
                $0.sequenceNumber = keys[Int(keychainKey.keyId)].sequenceNumber
            }

            self.getLatestBlockHeader(isSealed: true) {
                blockHeaderResponse in

                guard let blockHeader = blockHeaderResponse.result as? FlowBlockHeader else {
                    completion(RpcResponse(result: nil, error: FlowError.unknownError))
                    return
                }

                transaction.referenceBlockId = blockHeader.id
                transaction.set {
                    $0.script = script
                    $0.arguments = arguments
                    $0.gasLimit = 9999
                    $0.payer = payer
                    $0.authorizers = [proposer]
                }
                let signer = FlowTransactionSigner(keychain)

                do {
                    try signer.signTransaction(transaction)
                } catch {
                    completion(RpcResponse(result: nil, error: FlowError.unknownError))
                }

                self.sendTransaction(transaction) {
                    response in

                    guard let result = response.result as? FlowIdentifier else {
                        completion(RpcResponse(result: nil, error: FlowError.unknownError))
                        return
                    }

                    completion(RpcResponse(result: result, error: nil))
                }
            }
        }
    }
}
