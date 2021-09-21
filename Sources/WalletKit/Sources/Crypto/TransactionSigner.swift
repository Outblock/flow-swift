import FlowFoundation
import Foundation

public class FlowTransactionSigner {
    public var keychain: FlowKeyChainProtocol
//    public var signerAccounts: [String] = [String]()

    public init(_ keychain: FlowKeyChainProtocol) {
        self.keychain = keychain
    }

//    public func getTransactionDomainTag() -> Data {
//        let tag = "FLOW-V0.0-transaction"
//        var d: Data = tag.data(using: .ascii)!
//        return d.padRightZero(32)
//    }

//    public func getPayload() -> [Any] {
//        return [
//            transaction.script,
//            transaction.arguments.map { arg in arg.toJSON() },
//            transaction.referenceBlockId.data.padLeftZero(32),
//            transaction.gasLimit,
//            transaction.proposalKey.address.data,
//            transaction.proposalKey.keyId,
//            transaction.proposalKey.sequenceNumber,
//            transaction.payer.data,
//            transaction.authorizers.map { $0.data },
//        ]
//    }
//
//    public func getEnvelope() -> [Any] {
//        return [
//            self.getPayload(),
//            transaction.payloadSignatures.map {
//                [
//                    $0.signerIndex,
//                    $0.keyId,
//                    $0.signature,
//                ]
//            },
//        ]
//    }
//
//    public func getPayloadEncoded() -> Data {
//        let rlpEncoded = try! RLP.encode(getPayload())
//        return Data(rlpEncoded)
//    }
//
//    public func getEnvelopeEncoded() -> Data {
//        let rlpEncoded = try! RLP.encode(getEnvelope())
//        return Data(rlpEncoded)
//    }
//
//    public func getSignerIndex(_ address: Flow.Address) -> Int {
//        guard let signerIndex = signerAccounts.firstIndex(of: address.hex) else {
//            signerAccounts.append(address.hex)
//            return signerAccounts.firstIndex(of: address.hex)!
//        }
//        return signerIndex
//    }

    private func fetchKeyIndex(address: Flow.Address) throws -> Int {
        guard let index = try? keychain.getKeyGroup(address: address).keys.first?.keyId else {
            throw KeyChainError.accountNotFound
        }

        return index
    }

    public func signTransaction(unsignTransaction: Flow.Transaction) throws {
        var transaction = unsignTransaction
        guard let encodedPayload = transaction.encodedPayload else {
            return
        }

        let signData = Flow.DomainTag.transaction.normalize + encodedPayload
        if transaction.proposalKey.address.hex != transaction.payerAddress.hex {
            let signature = try keychain.signData(address: transaction.proposalKey.address, payload: signData)
            _ = transaction.addPayloadSignature(address: transaction.proposalKey.address,
                                                keyIndex: transaction.proposalKey.keyIndex,
                                                signature: signature)
        }

        for authorizer in transaction.authorizers {
            if transaction.proposalKey.address.hex == authorizer.hex {
                continue
            }
            let signature = try keychain.signData(address: authorizer, payload: encodedPayload)
            let keyIndex = try fetchKeyIndex(address: authorizer)
            _ = transaction.addPayloadSignature(address: authorizer,
                                                keyIndex: keyIndex,
                                                signature: signature)
        }

        guard let encodedEnvelope = transaction.encodedEnvelope else {
            return
        }
        let signData2 = Flow.DomainTag.transaction.normalize + encodedEnvelope
        let signature = try keychain.signData(address: transaction.payerAddress, payload: signData2)
        let keyIndex = try fetchKeyIndex(address: transaction.payerAddress)
        _ = transaction.addEnvelopeSignature(address: transaction.payerAddress, keyIndex: keyIndex, signature: signature)
    }
}
