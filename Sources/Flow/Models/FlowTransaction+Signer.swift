//
//  FlowTransaction + Signer
//
//  Copyright 2021 Zed Labs Pty Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

extension Flow {
    /// Sign the unsigned transaction with a list of `FlowSigner`
    /// - parameters:
    ///     - unsignedTransaction: The transaction to be signed
    ///     - signers: A list of `FlowSigner` to sign the transaction
    /// - returns: The signed transaction
    public func signTransaction(unsignedTransaction: Flow.Transaction, signers: [FlowSigner]) throws -> Flow.Transaction {
        var tx = unsignedTransaction
        return try tx.sign(signers: signers)
    }
}

extension Flow.Transaction {
    /// Sign (Mutate) the payload of Flow Transaction with a list of `FlowSigner`
    /// - parameters:
    ///     - signers: A list of `FlowSigner` to sign the transaction
    /// - returns: The `Flow.Transaction` itself.
    @discardableResult
    public mutating func signPayload(signers: [FlowSigner]) throws -> Flow.Transaction {
        guard let signablePlayload = signablePlayload else {
            throw Flow.FError.invaildPlayload
        }

        func findSigners(address: Flow.Address, signers: [FlowSigner]) -> [FlowSigner]? {
            return signers.filter { $0.address == address }
        }

        // Sign with the proposal key first.
        // If proposer is same as payer, we skip this step
        if proposalKey.address != payerAddress {
            guard let signers = findSigners(address: proposalKey.address, signers: signers) else {
                throw Flow.FError.missingSigner
            }
            for signer in signers {
                let signature = try signer.sign(signableData: signablePlayload)
                addPayloadSignature(address: signer.address,
                                    keyIndex: signer.keyIndex,
                                    signature: signature)
            }
        }

        // Sign the transaction with each authorizer
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
                let signature = try signer.sign(signableData: signablePlayload)
                addPayloadSignature(address: authorizer,
                                    keyIndex: signer.keyIndex,
                                    signature: signature)
            }
        }

        return self
    }

    /// Sign (Mutate) the envelope of Flow Transaction with a list of `FlowSigner`
    /// - parameters:
    ///     - signers: A list of `FlowSigner` to sign the transaction
    /// - returns: The `Flow.Transaction` itself.
    @discardableResult
    public mutating func signEnvelope(signers: [FlowSigner]) throws -> Flow.Transaction {
        guard let signableEnvelope = signableEnvelope else {
            throw Flow.FError.invaildEnvelope
        }

        func findSigners(address: Flow.Address, signers: [FlowSigner]) -> [FlowSigner]? {
            return signers.filter { $0.address == address }
        }

        guard let signers = findSigners(address: payerAddress,
                                        signers: signers) else {
            throw Flow.FError.missingSigner
        }

        // Sign the transaction with payer
        for signer in signers {
            let signature = try signer.sign(signableData: signableEnvelope)
            addEnvelopeSignature(address: payerAddress,
                                 keyIndex: signer.keyIndex,
                                 signature: signature)
        }
        return self
    }

    // TODO: Replace it with the combination of `signPayload` and `signEnvelope`

    /// Sign (Mutate) unsigned Flow Transaction with a list of `FlowSigner`
    /// - parameters:
    ///     - signers: A list of `FlowSigner` to sign the transaction
    /// - returns: The `Flow.Transaction` itself.
    @discardableResult
    public mutating func sign(signers: [FlowSigner]) throws -> Flow.Transaction {
        try signPayload(signers: signers)
        try signEnvelope(signers: signers)
        return self
    }
}
