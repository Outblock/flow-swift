import Foundation
import Swift

// extend business logic on FlowClient

public class FlowClient: FlowEntity {
    enum FlowError: LocalizedError {
        case unknownError
        case invalidAccount
        case keyNotFound
    }

    public var rpcProvider: FlowRpcClientProtocol = FlowGrpcClient(host: "127.0.0.1", port: 3569)

    public override init() {}

    public func ping(completion: @escaping (ResultCallback)) {
        rpcProvider.ping(completion: completion)
    }

    public func addKeyToAccount(_ account: FlowAddress, publicKey: String, keychain: FlowKeyChainProtocol, completion: @escaping (ResultCallback)) {
        let script = """
        transaction(publicKey: String) {
            prepare(signer: AuthAccount) {
                signer.addPublicKey(publicKey.decodeHex())
            }
        }
        """
        sendTransaction(script: script,
                        arguments: [CadenceString(publicKey)],
                        proposer: account,
                        payer: account,
                        authorizers: [account],
                        keychain: keychain, completion: completion)
    }

    public func addContractToAccount(account: FlowAddress, keychain: FlowKeyChainProtocol, contractName: String, code: String, completion: @escaping (ResultCallback)) {
        let script = """
        transaction(name: String, code: String) {
            prepare(signer: AuthAccount) {
                signer.contracts.add(name: name, code: code.decodeHex())
            }
        }
        """
        let codeEncoded = code.data(using: .utf8)?.hexString()

        sendTransaction(script: script,
                        arguments: [CadenceString(contractName),
                                    CadenceString(codeEncoded!)],
                        proposer: account,
                        payer: account,
                        authorizers: [account],
                        keychain: keychain, completion: completion)
    }

    public func createAccount(account: FlowAddress, keychain: FlowKeyChainProtocol, publicKeys: [String], contracts: [String: String], completion: @escaping (ResultCallback)) {
        let script = """
        transaction(publicKeys: [String], contracts: {String: String}) {
            prepare(signer: AuthAccount) {
                let acct = AuthAccount(payer: signer)
                for key in publicKeys {
                    acct.addPublicKey(key.decodeHex())
                }
                for contract in contracts.keys {
                    acct.contracts.add(name: contract, code: contracts[contract]!.decodeHex())
                }
            }
        }
        """
        var encodedKeys: [CadenceValue] = []
        for publicKey in publicKeys {
            encodedKeys.append(CadenceString(publicKey))
        }

        var encodedContractsValues: [CadenceDictionary.InnerElement] = []

        for contract in contracts.keys {
            let codeEncoded = contracts[contract]!.data(using: .utf8)!.hexString()

            let inner = CadenceDictionary.InnerElement(CadenceString(contract),
                                                       value: CadenceString(codeEncoded))
            encodedContractsValues.append(inner)
        }

        try! sendTransaction(script: script,
                             arguments: [CadenceArray(value: publicKeys.map { CadenceString($0) }),
                                         CadenceDictionary(value: encodedContractsValues)],
                             proposer: account,
                             payer: account,
                             authorizers: [account],
                             keychain: keychain, completion: completion)
    }

    public func removeAccountKeyByIndex(_ account: FlowAddress, keychain: FlowKeyChainProtocol, index: Int, completion: @escaping (ResultCallback)) {
        let script = """
        transaction(keyIndex: Int) {
        prepare(signer: AuthAccount) {
            signer.removePublicKey(keyIndex)
        }
        """
        sendTransaction(script: script,
                        arguments: [CadenceInt(index)],
                        proposer: account,
                        payer: account,
                        authorizers: [account],
                        keychain: keychain, completion: completion)
    }

    public func removeContractFromAccount(_ account: FlowAddress, contractName: String, keychain: FlowKeyChainProtocol, index _: Int, completion: @escaping (ResultCallback)) {
        let script = """
        transaction(name: String) {
            prepare(signer: AuthAccount) {
                signer.contracts.remove(name: name)
            }
        }
        """
        sendTransaction(script: script,
                        arguments: [CadenceString(contractName)],
                        proposer: account,
                        payer: account,
                        authorizers: [account],
                        keychain: keychain, completion: completion)
    }

    public func updateContractOfAccount(_ account: FlowAddress, contractName: String, newCode: String, keychain: FlowKeyChainProtocol, index _: Int, completion: @escaping (ResultCallback)) {
        let script = """
        transaction(name: String, code: String) {
            prepare(signer: AuthAccount) {
                signer.contracts.update__experimental(name: name, code: code.decodeHex())
            }
        }
        """
        let codeEncoded = newCode.data(using: .utf8)?.hexString()

        sendTransaction(script: script,
                        arguments: [CadenceString(contractName),
                                    CadenceString(codeEncoded!)],
                        proposer: account,
                        payer: account,
                        authorizers: [account],
                        keychain: keychain, completion: completion)
    }
}
