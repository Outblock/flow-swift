import Foundation
import PromiseKit

extension FlowClient {
    public func sendTransaction(script: String, arguments: [CadenceValue], singleSigner: String, keychain: FlowKeyChainProtocol) -> Promise<FlowIdentifier> {
        let proposer = FlowAddress.from(singleSigner)!
        return sendTransaction(script: script,
                               arguments: arguments,
                               proposer: proposer,
                               payer: proposer,
                               authorizers: [proposer],
                               keychain: keychain)
    }

    public func getTransactionResult(id: FlowIdentifier) -> Promise<FlowTransactionResult> {
        return Promise<FlowTransactionResult> { task in

            self.getTransactionResult(id: id) {
                response in

                guard let result = response.result as? FlowTransactionResult else {
                    task.reject(response.error!)
                    return
                }

                task.fulfill(result)
            }
        }
    }

    public func sendTransaction(script: String, arguments: [CadenceValue], proposer: FlowAddress, payer: FlowAddress, authorizers _: [FlowAddress], keychain: FlowKeyChainProtocol) -> Promise<FlowIdentifier> {
        return Promise<FlowIdentifier> { task in

            let transaction: FlowTransaction = FlowTransaction()

            let account = try! self.getAccount(proposer).wait()

            guard let keychainKey = try keychain.getKeyGroup(address: proposer).keys.first else {
                throw FlowError.keyNotFound
            }

            let keys = account.keys

            transaction.proposalKey.set {
                $0.address = proposer
                $0.keyId = keychainKey.keyId
                $0.sequenceNumber = keys[Int(keychainKey.keyId)].sequenceNumber
            }
            let blockHeader = try! self.getLatestBlockHeader(isSealed: true).wait()

            transaction.referenceBlockId = blockHeader.id
            transaction.set {
                $0.script = script
                $0.arguments = arguments
                $0.gasLimit = 1000
                $0.payer = payer
                $0.authorizers = [proposer]
            }

            let signer = FlowTransactionSigner(keychain)
            try signer.signTransaction(transaction)

            self.sendTransaction(transaction) {
                response in

                guard let result = response.result as? FlowIdentifier else {
                    task.reject(response.error!)
                    return
                }

                task.fulfill(result)
            }
        }
    }
}
