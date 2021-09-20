import Foundation

public class FlowTransactionSigner {
    public var transaction: FlowTransaction = FlowTransaction()
    public var keychain: FlowKeyChainProtocol
    public var signerAccounts: [String] = [String]()

    public init(_ keychain: FlowKeyChainProtocol) {
        self.keychain = keychain
    }

    public func getTransactionDomainTag() -> Data {
        let tag = "FLOW-V0.0-transaction"
        var d: Data = tag.data(using: .ascii)!
        return d.padRightZero(32)
    }

    public func getPayload() -> [Any] {
        return [
            transaction.script,
            transaction.arguments.map { arg in arg.toJSON() },
            transaction.referenceBlockId.data.padLeftZero(32),
            transaction.gasLimit,
            transaction.proposalKey.address.data,
            transaction.proposalKey.keyId,
            transaction.proposalKey.sequenceNumber,
            transaction.payer.data,
            transaction.authorizers.map { $0.data },
        ]
    }

    public func getEnvelope() -> [Any] {
        return [
            self.getPayload(),
            transaction.payloadSignatures.map {
                [
                    $0.signerIndex,
                    $0.keyId,
                    $0.signature,
                ]
            },
        ]
    }

    public func getPayloadEncoded() -> Data {
        let rlpEncoded = try! RLP.encode(getPayload())
        return Data(rlpEncoded)
    }

    public func getEnvelopeEncoded() -> Data {
        let rlpEncoded = try! RLP.encode(getEnvelope())
        return Data(rlpEncoded)
    }

    public func getSignerIndex(_ address: FlowAddress) -> Int {
        guard let signerIndex = signerAccounts.firstIndex(of: address.hex) else {
            signerAccounts.append(address.hex)
            return signerAccounts.firstIndex(of: address.hex)!
        }
        return signerIndex
    }

    public func signTransaction(_ transaction: FlowTransaction) throws {
        self.transaction = transaction

        var encodedPayload = getPayloadEncoded()
        encodedPayload.insert(contentsOf: getTransactionDomainTag(), at: 0)

        if transaction.proposalKey.address.hex != transaction.payer.hex {
            let signature = try keychain.signData(signerIndex: getSignerIndex(transaction.proposalKey.address),
                                                  address: transaction.proposalKey.address,
                                                  payload: encodedPayload)
            transaction.payloadSignatures.append(signature)
        }

        for authorizer in transaction.authorizers {
            if transaction.proposalKey.address.hex == authorizer.hex {
                continue
            }
            let signature = try keychain.signData(signerIndex: getSignerIndex(authorizer),
                                                  address: authorizer,
                                                  payload: encodedPayload)
            transaction.payloadSignatures.append(signature)
        }

        var encodedEnvelope = getEnvelopeEncoded()
        encodedEnvelope.insert(contentsOf: getTransactionDomainTag(), at: 0)
        let signature = try keychain.signData(signerIndex: getSignerIndex(transaction.payer),
                                              address: transaction.payer,
                                              payload: encodedEnvelope)
        transaction.envelopeSignatures.append(signature)
    }
}
