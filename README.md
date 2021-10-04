# Flow Swift SDK
The Flow SDK is a Swift Library for Flow blockchain (https://www.onflow.org). 

### Features

Currently the following Flow Features have been implemented:

- [x] Access API gRPC
- [x] RLP encode & decode
- [x] Cadence type support
- [x] Transaction DSL
- [x] Send Transaction
- [x] Execute script with argument
- [x] Handle multiple signatures and keys 

## Installation

This is a Swift Package, and can be installed via Xcode with the URL of this repository:

```swift
.package(name: "Flow", url: "https://github.com/zed-io/flow-swift.git", from: "0.0.4-beta")
```

## Config

To config the SDK, you will just need provider the chainID for it. The default chainID is **Mainnet**.
If you want to use mainnet, you can ignore this configuration.
```swift
flow.configure(chainID: .testnet)
```

If you want to use a custom gRPC for the access API, you can definite your own one.
```swift
let endpoint = Flow.ChainID.Endpoint(node: "flow-testnet.g.alchemy.com", port: 443)
let chainID = Flow.ChainID.custom(name: "Alchemy-Testnet", endpoint:endpoint)
flow.configure(chainID: chainID)
``` 

## Access API 

Here are some example how to create a gRPC client in the SDK to make access API call.
For more info about access API, please check this [official website](https://docs.onflow.org/access-api/#gatsby-focus-wrapper)

### Block callback
```swift
flow.accessAPI.getNetworkParameters { result in
    switch result {
    case let .success(chainID):
        print(chainID)
    case let .failure(error):
        print(error)
    }
}
```

### NIO EventLoopFuture
```swift
let testnet = flow.createAccessAPI(chainID: .testnet)
let call = testnet.getTransactionResultById(id: Flow.ID(hex: "0x1"))
call.whenSuccess { result in
    print(result)
}
call.whenFailure { error in
    print(error)
}
```

## Transaction

In this SDK, you could build a transaction and send it to the chain.

### Build a transaction 
```swift
let tx = try? flow.buildTransaction {
    cadence {
        """
            transaction(publicKey: String) {
                prepare(signer: AuthAccount) {
                    signer.addPublicKey(publicKey.decodeHex())
                }
            }
        """
    }

    proposer {
        address
    }

    authorizers {
        address
    }

    arguments {
        .init(value: .string(value: <PublicKey>))
    }

    // optional
    gasLimit {
        1000
    }
}
```

### Send a transaction

To send a transaction to the chain, you need attach signers in here, which need to confirm **FlowSigner** protocol

```swift
public protocol FlowSigner {
    var address: Flow.Address { get set }
    var keyIndex: Int { get set }
    func signature(signableData: Data) throws -> Data
}

let txId = try! flow.sendTransaction(signers: flowSigners) {
    cadence {
        """
            transaction {
                prepare(signer1: AuthAccount, signer2: AuthAccount, signer3: AuthAccount) {
                  log(signer1.address)
                  log(signer2.address)
                  log(signer3.address)
              }
            }
        """
    }

    proposer {
        .init(address: addressA, keyIndex: 4)
    }

    payer {
        addressB
    }

    authorizers {
        [addressC, addressB, addressA]
    }
}.wait()
```
