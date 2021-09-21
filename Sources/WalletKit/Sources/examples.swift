import CryptoKit
import Foundation

// public func example_SendTransactionSingleSigner() {
//    let client = FlowClient()
//
//    var keychain: MemoryKeychain = MemoryKeychain()
//    try keychain.addKey(address: FlowAddress("f8d6e0586b0a20c7"),
//                        key: FlowKey(address: FlowAddress("f8d6e0586b0a20c7"),
//                                     keyId: 0,
//                                     key: "38b6f958c11a79312b1e44ba825299c03b9eaa362d571662366cdb4e08b59c32",
//                                     signingAlgorithm: FlowSignatureAlgorithm.ECDSA_P256,
//                                     hashAlgorithm: FlowHashAlgorithm.SHA3_256))
//
//    var script = "transaction {prepare(acct: AuthAccount) {} execute {}}"
//
//    _ = try client.sendTransaction(script: script, singleSigner: "f8d6e0586b0a20c7", keychain: keychain).done {
//        result in
//        let txid = result
//    }.wait()
//
//    _ = try client.getTransactionResult(id: FlowIdentifier("1d5315640e6dd20e28a1bf21ecc11964380a748915e69d4374f3ada497571a3b")).done {
//        txResult in
//        print(txResult.pretty)
//
//        for event in txResult.events {
//            var payload = event.payload!
//
//            print(payload.id)
//
//            for field in payload.fields {
//                print(field)
//            }
//        }
//    }
//
//    RunLoop.main.run()
// }
