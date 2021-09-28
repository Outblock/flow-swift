//
//  File.swift
//  File
//
//  Created by lmcmz on 29/9/21.
//

import Foundation

extension Flow {
    public func signTransaction(unsignedTransaction: Flow.Transaction, signers: [FlowSigner]) throws -> Flow.Transaction {
        var tx = unsignedTransaction
        return try tx.sign(signers: signers)
    }
}

extension Flow.Transaction {
    public mutating func sign(signers: [FlowSigner]) throws -> Flow.Transaction {
        guard let signablePlayload = signablePlayload else {
            throw Flow.FError.invaildPlayload
        }

        func findSigners(address: Flow.Address, signers: [FlowSigner]) -> [FlowSigner]? {
            return signers.filter { $0.address == address }
        }

        if proposalKey.address != payerAddress {
            guard let signers = findSigners(address: proposalKey.address, signers: signers) else {
                throw Flow.FError.missingSigner
            }
            for signer in signers {
                let signature = try! signer.signature(signableData: signablePlayload)
                _ = addPayloadSignature(address: signer.address,
                                        keyIndex: signer.keyIndex,
                                        signature: signature)
            }
        }

        for authorizer in authorizers {
            if proposalKey.address == authorizer {
                continue
            }

            if payerAddress == authorizer {
                continue
            }

            guard let signers = findSigners(address: authorizer, signers: signers) else {
                throw Flow.FError.missingSigner
            }

            for signer in signers {
                let signature = try! signer.signature(signableData: signablePlayload)
                _ = addPayloadSignature(address: authorizer,
                                        keyIndex: signer.keyIndex,
                                        signature: signature)
            }
        }

        guard let signableEnvelope = signableEnvelope else {
            throw Flow.FError.invaildEnvelope
        }

        guard let signers = findSigners(address: payerAddress,
                                        signers: signers) else {
            throw Flow.FError.missingSigner
        }

        for signer in signers {
            let signature = try! signer.signature(signableData: signableEnvelope)
            _ = addEnvelopeSignature(address: payerAddress,
                                     keyIndex: signer.keyIndex,
                                     signature: signature)
        }
        return self
    }
}
