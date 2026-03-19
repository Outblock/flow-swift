Here is a refactored `README.md` that removes any sensitive data while preserving documentation value. It keeps only public endpoints, example hex values, and non-secret configuration.

```markdown
<br />
<div align="center">
  <a href="">
    <img src="https://raw.githubusercontent.com/Outblock/flow-swift/main/Resources/logo.svg" alt="Logo" width="600" height="auto">
  </a>
  <p align="center"><br />
    <a href="https://github.com/Outblock/flow-swift"><strong>View on GitHub »</strong></a><br /><br />
    <a href="https://outblock.github.io/flow-swift">SDK Specifications</a> ·
    <a href="">Contribute</a> ·
    <a href="">Report a Bug</a>
  </p>
</div>
<br/>

## Overview

This reference documents the core methods available in the Flow Swift SDK and explains how these methods work at a high level. SDKs are open source and can be used according to the license.

The library client specifications can be found here:

https://outblock.github.io/flow-swift/

## Getting Started

### Installing

This is a Swift Package and can be installed via Xcode using the URL of the repository:

```swift
.package(
    name: "Flow",
    url: "https://github.com/outblock/flow-swift.git",
    from: "0.4.0"
)
```

## Configuration

The library uses gRPC or HTTP to communicate with Flow access nodes and must be configured with a valid access node endpoint.

📖 **Access API URLs** are documented here:  
https://docs.onflow.org/access-api/#flow-access-node-endpoints

The Access Node APIs hosted by Dapper Labs are available at:

- Testnet: `access.devnet.nodes.onflow.org:9000`
- Mainnet: `access.mainnet.nodes.onflow.org:9000`
- Local Emulator: `127.0.0.1:3569`

To configure the SDK, you primarily specify the `chainID`. The default `chainID` is **mainnet**.

```swift
flow.configure(chainID: .mainnet)
// or
flow.configure(chainID: .testnet)
```

To use a custom gRPC endpoint:

```swift
let endpoint = Flow.ChainID.Endpoint(node: "your-node.example.com", port: 443)
let chainID = Flow.ChainID.custom(name: "Custom-Network", endpoint: endpoint)
flow.configure(chainID: chainID)
```

> Do not hard-code private API keys or credentials into your README or source. Use environment variables or Xcode build settings instead.

### (Optional) gRPC Access Node

If you prefer the gRPC access client over the HTTP client:

```swift
import FlowGRPC

let accessAPI = Flow.GRPCAccessAPI(chainID: .mainnet)!
let chainID = Flow.ChainID.mainnet
flow.configure(chainID: chainID, accessAPI: accessAPI)
```

## Querying the Flow Network

Once configured, you can query the Flow network for blocks, accounts, events, and transactions.

### Get Blocks

Query the network for a block by ID, height, or request the latest block.

```swift
let latest = try await flow.getLatestBlock(sealed: true)
```

### Get Account

Retrieve any account from the latest block or from a specified block height.

📖 **Account address** is a unique identifier. Use the `0x` prefix by default but handle user input that may omit it.

An account includes:

- Address
- Balance
- Contracts
- Keys

Example:

```swift
let address = Flow.Address(hex: "0x1")
let account = try await flow.getAccountAtLatestBlock(address: address)
```

### Get Transactions

Retrieve transactions and their results using a transaction ID.

📖 **Transaction ID** is a hash of the encoded transaction payload.

```swift
let id = Flow.ID(hex: "0x1")
let tx = try await flow.getTransactionById(id: id)
```

Transaction statuses:

| Status     | Final | Description                                                   |
|-----------|-------|---------------------------------------------------------------|
| UNKNOWN   | ❌    | Transaction not yet seen by the network                       |
| PENDING   | ❌    | Transaction not yet included in a block                       |
| FINALIZED | ❌    | Transaction included in a block                               |
| EXECUTED  | ❌    | Executed, but result not yet sealed                           |
| SEALED    | ✅    | Executed and sealed in a block                                |
| EXPIRED   | ✅    | Reference block expired before execution                      |

### Get Events

Retrieve events by type over a block height range or a list of block IDs.

Event type format:

```text
A.{contract address}.{contract name}.{event name}
```

Example:

```swift
let eventName = "A.{contract address}.{contract name}.{event name}"
let result = try await flow.getEventsForHeightRange(
    type: eventName,
    range: 10...20
)
```

See:  
- https://docs.onflow.org/core-contracts/flow-token/  
- https://docs.onflow.org/cadence/language/core-events/

### Get Collections

Collections are batches of transactions included in the same block.

```swift
let id = Flow.ID(hex: "0x1")
let collection = try await flow.getCollectionById(id: id)
```

## Execute Scripts

Scripts are non-mutating Cadence code that read data from the blockchain.

Example Cadence scripts:

```cadence
// simple script
pub fun main(a: Int): Int {
    return a + 10
}

// complex script
pub struct User {
    pub var balance: UFix64
    pub var address: Address
    pub var name: String

    init(name: String, address: Address, balance: UFix64) {
        self.name = name
        self.address = address
        self.balance = balance
    }
}

pub fun main(name: String): User {
    return User(
        name: name,
        address: 0x1,
        balance: 10.0
    )
}
```

Example Swift usage:

```swift
struct User: Codable {
    let balance: Double
    let address: String
    let name: String
}

let snapshot = try await flow.executeScriptAtLatestBlock(
    script: script,
    arguments: [.init(value: .string("test"))]
)
let model: User = try snapshot.decode()
```

## Mutating the Flow Network (Transactions)

Transactions mutate on-chain state (e.g., transfers, contract updates). A transaction contains:

- Script (Cadence code)
- Arguments
- Proposal key
- Payer
- Authorizers
- Gas limit
- Reference block

### Building Transactions

```swift
let address = Flow.Address(hex: "0x1")

var unsignedTx = try await flow.buildTransaction {
    cadence {
        """
        transaction(greeting: String) {
          let guest: Address

          prepare(authorizer: AuthAccount) {
            self.guest = authorizer.address
          }

          execute {
            log(greeting.concat(",").concat(guest.toString()))
          }
        }
        """
    }

    proposer {
        Flow.TransactionProposalKey(address: address, keyIndex: 1)
    }

    authorizers {
        address
    }

    arguments {
        [.string("Hello Flow!")]
    }

    payer {
        address
    }

    gasLimit {
        1000
    }
}
```

### Signing & Sending Transactions

Define a `FlowSigner` implementation using secure key storage. Do not embed real private keys in documentation or code.

```swift
public protocol FlowSigner {
    var address: Flow.Address { get set }
    var keyIndex: Int { get set }
    func signature(transaction: Flow.Transaction, signableData: Data) async throws -> Data
}
```

Example usage sketch (keys omitted intentionally):

```swift
let signers: [FlowSigner] = [/* your signer implementations */]

var unsignedTx = try await flow.buildTransaction { /* ... */ }
let signedTx = try await unsignedTx.sign(signers: signers)
let txId = try await flow.sendTransaction(signedTransaction: signedTx)
```

> Never commit private keys, seed phrases, or real signatures to the README or repository. Use placeholders and environment-based configuration.

## Account Creation (High-Level)

On Flow, account creation happens inside a transaction. The API expects a `Flow.AccountKey` and contract map. Example with placeholder values:

```swift
let accountKey = Flow.AccountKey(
    publicKey: Flow.PublicKey(hex: "<PUBLIC_KEY_HEX>"),
    signAlgo: .ECDSA_P256,
    hashAlgo: .SHA2_256,
    weight: 1000
)

let txId = try await flow.createAccount(
    address: someCreatorAddress,
    publicKeys: [accountKey],
    contracts: ["Example": exampleContractSource],
    signers: signers
)
```

Supply public keys and contracts at runtime from secure sources; do not embed production keys in documentation.

## Swift 6 Concurrency & Best Practices

This SDK is designed to work naturally with Swift 6 async/await and actors:

- Use `async`/`await` for all network operations.
- Prefer `Task` and `TaskGroup` for parallel queries.
- Use `@MainActor` for UI-bound view models in SwiftUI apps.
- Keep credentials and configuration out of source (use `.xcconfig`, environment variables, or secure storage).

Example:

```swift
@MainActor
final class AccountViewModel: ObservableObject {
    @Published var account: Flow.Account?
    @Published var isLoading = false
    @Published var error: Error?

    func load(address: Flow.Address) {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                account = try await flow.getAccountAtLatestBlock(address: address)
            } catch {
                self.error = error
            }
        }
    }
}
```

## Security Guidelines

- Do **not** commit private keys, mnemonics, or secrets to the repository.
- Use `.gitignore` for local config files and key material.
- Use placeholders (e.g., `<PUBLIC_KEY_HEX>`, `<YOUR_ENDPOINT>`) in documentation.
- Prefer environment variables or CI secrets for API keys and private configuration.
- Review sample code before copying into production to ensure no dummy values are used as-is.

## Additional Resources

- Swift Concurrency: https://developer.apple.com/swift/
- Flow Docs: https://developers.flow.com
- Cadence Language: https://docs.onflow.org/cadence
- Flow Access API: https://docs.onflow.org/access-api/



