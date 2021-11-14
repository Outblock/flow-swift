<br />
<div align="center">
  <a href="">
    <img src="./Resources/logo.svg" alt="Logo" width="600" height="auto">
  </a>
  <p align="center"> <br />
    <a href="https://github.com/zed-io/flow-swift"><strong>View on GitHub »</strong></a> <br /><br />
    <a href="https://zed-io.github.io/flow-swift">SDK Specifications</a> ·
    <a href="">Contribute</a> ·
    <a href="">Report a Bug</a>
  </p>
</div>
<br/>

## Overview 

This reference documents all the methods available in the SDK, and explains in detail how these methods work.
SDKs are open source, and you can use them according to the licence.

The library client specifications can be found here:

https://outblock.github.io/flow-swift/


## Getting Started

### Installing

This is a Swift Package, and can be installed via Xcode with the URL of this repository:

```swift
.package(name: "Flow", url: "https://github.com/outblock/flow-swift.git", from: "0.1.3-beta")
```

## Config

The library uses gRPC to communicate with the access nodes and it must be configured with correct access node API URL. 

📖 **Access API URLs** can be found [here](https://docs.onflow.org/access-api/#flow-access-node-endpoints). An error will be returned if the host is unreachable.
The Access Nodes APIs hosted by DapperLabs are accessible at:
- Testnet `access.devnet.nodes.onflow.org:9000`
- Mainnet `access.mainnet.nodes.onflow.org:9000`
- Local Emulator `127.0.0.1:3569` 

To config the SDK, you just need to provider the chainID for it. The default chainID is **Mainnet**.
For example, if you want to use testnet, you can config the chainID like this:
```swift
flow.configure(chainID: .testnet)
```

Moreover, if you want to use a custom gRPC endpoint for the access API, here is the way to do it:
```swift
let endpoint = Flow.ChainID.Endpoint(node: "flow-testnet.g.alchemy.com", port: 443)
let chainID = Flow.ChainID.custom(name: "Alchemy-Testnet", endpoint:endpoint)
flow.configure(chainID: chainID)
```


## Querying the Flow Network
After you have established a connection with an access node, you can query the Flow network to retrieve data about blocks, accounts, events and transactions. We will explore how to retrieve each of these entities in the sections below.

### Get Blocks
Query the network for block by id, height or get the latest block.

📖 **Block ID** is SHA3-256 hash of the entire block payload. This hash is stored as an ID field on any block response object (ie. response from `GetLatestBlock`). 

📖 **Block height** expresses the height of the block on the chain. The latest block height increases by one for every valid block produced.

#### Examples

This example depicts ways to get the latest block as well as any other block by height or ID:
```swift
flow.accessAPI.getLatestBlock(sealed: true).whenComplete { result in
    switch result {
    case let .success(block):
        // Handle Success Result
    case let .failure(error):
        // Handle Error
    }
}
```

### Get Account

Retrieve any account from Flow network's latest block or from a specified block height.

📖 **Account address** is a unique account identifier. Be mindful about the `0x` prefix, you should use the prefix as a default representation but be careful and safely handle user inputs without the prefix.

An account includes the following data:
- Address: the account address.
- Balance: balance of the account.
- Contracts: list of contracts deployed to the account.
- Keys: list of keys associated with the account.

#### Examples
Example depicts ways to get an account at the latest block and at a specific block height:

```swift
let address = Flow.Address(hex: "0x1")
flow.accessAPI.getAccountAtLatestBlock(address: address).whenComplete { result in
    switch result {
    case let .success(account):
        // Handle Success Result
    case let .failure(error):
        // Handle Error
    }
}
```

### Get Transactions

Retrieve transactions from the network by providing a transaction ID. After a transaction has been submitted, you can also get the transaction result to check the status.

📖 **Transaction ID** is a hash of the encoded transaction payload and can be calculated before submitting the transaction to the network.

⚠️ The transaction ID provided must be from the current spork.

📖 **Transaction status** represents the state of transaction in the blockchain. Status can change until is finali
.

| Status      | Final | Description |
| ----------- | ----------- | ----------- |
|   UNKNOWN    |    ❌   |   The transaction has not yet been seen by the network  |
|   PENDING    |    ❌   |   The transaction has not yet been included in a block   |
|   FINALIZED    |   ❌     |  The transaction has been included in a block   |
|   EXECUTED    |   ❌    |   The transaction has been executed but the result has not yet been sealed  |
|   SEALED    |    ✅    |   The transaction has been executed and the result is sealed in a block  |
|   EXPIRED    |   ✅     |  The transaction reference block is outdated before being executed    |


```swift
let id = Flow.ID(hex: "0x1")
flow.accessAPI.getTransactionById(id: id).whenComplete { result in
    switch result {
    case let .success(tx):
        // Handle Success Result
    case let .failure(error):
        // Handle Error
    }
}
```


### Get Events
Retrieve events by a given type in a specified block height range or through a list of block IDs.

📖 **Event type** is a string that follow a standard format:
```
A.{contract address}.{contract name}.{event name}
```

Please read more about [events in the documentation](https://docs.onflow.org/core-contracts/flow-token/). The exception to this standard are 
core events, and you should read more about them in [this document](https://docs.onflow.org/cadence/language/core-events/).

📖 **Block height range** expresses the height of the start and end block in the chain.

#### Examples
Example depicts ways to get events within block range or by block IDs:

```swift
let eventName = "A.{contract address}.{contract name}.{event name}"
let blockIds: [Flow.ID] = [.init(hex: "0x1"), .init(hex: "0x2") ]
flow.accessAPI.getEventsForHeightRange(type: eventName, range: 10...20).whenComplete { result in
    switch result {
    case let .success(response):
        // Handle Success Result
    case let .failure(error):
        // Handle Error
    }
}
```


### Get Collections
Retrieve a batch of transactions that have been included in the same block, known as ***collections***. 
Collections are used to improve consensus throughput by increasing the number of transactions per block and they act as a link between a block and a transaction.

📖 **Collection ID** is SHA3-256 hash of the collection payload.

Example retrieving a collection:
```swift
let id = Flow.ID(hex: "0x1")
flow.accessAPI.getCollectionById(id: id).whenComplete { result in
    switch result {
    case let .success(response):
        // Handle Success Result
    case let .failure(error):
        // Handle Error
    }
}
```

### Execute Scripts
Scripts allow you to write arbitrary non-mutating Cadence code on the Flow blockchain and return data. You can learn more about [Cadence and scripts here](https://docs.onflow.org/cadence/language/), but we are now only interested in executing the script code and getting back the data.

We can execute a script using the latest state of the Flow blockchain or we can choose to execute the script at a specific time in history defined by a block height or block ID.

📖 **Block ID** is SHA3-256 hash of the entire block payload, but you can get that value from the block response properties.

📖 **Block height** expresses the height of the block in the chain.
```
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
```swift
flow.accessAPI.executeScriptAtLatestBlock(script: script, arguments: [.init(value: .string("test"))]).whenComplete { result in
    switch result {
    case let .success(response):
        // Handle Success Result
    case let .failure(error):
        // Handle Error
    }
}
```

## Mutate Flow Network
Flow, like most blockchains, allows anybody to submit a transaction that mutates the shared global chain state. A transaction is an object that holds a payload, which describes the state mutation, and one or more authorizations that permit the transaction to mutate the state owned by specific accounts.

Transaction data is composed and signed with help of the SDK. The signed payload of transaction then gets submitted to the access node API. If a transaction is invalid or the correct number of authorizing signatures are not provided, it gets rejected. 

Executing a transaction requires couple of steps:
- [Building a transaction](#build-transactions).
- [Signing a transaction](#sign-transactions).
- [Sending a transaction](#send-transactions).

## Transactions
A transaction is nothing more than a signed set of data that includes script code which are instructions on how to mutate the network state and properties that define and limit it's execution. All these properties are explained bellow. 

📖 **Script** field is the portion of the transaction that describes the state mutation logic. On Flow, transaction logic is written in [Cadence](https://docs.onflow.org/cadence/). Here is an example transaction script:
```
transaction(greeting: String) {
  execute {
    log(greeting.concat(", World!"))
  }
}
```

📖 **Arguments**. A transaction can accept zero or more arguments that are passed into the Cadence script. The arguments on the transaction must match the number and order declared in the Cadence script. Sample script from above accepts a single `String` argument.

📖 **[Proposal key](https://docs.onflow.org/concepts/transaction-signing/#proposal-key)** must be provided to act as a sequence number and prevent reply and other potential attacks.

Each account key maintains a separate transaction sequence counter; the key that lends its sequence number to a transaction is called the proposal key.

A proposal key contains three fields:
- Account address
- Key index
- Sequence number

A transaction is only valid if its declared sequence number matches the current on-chain sequence number for that key. The sequence number increments by one after the transaction is executed.

📖 **[Payer](https://docs.onflow.org/concepts/transaction-signing/#signer-roles)** is the account that pays the fees for the transaction. A transaction must specify exactly one payer. The payer is only responsible for paying the network and gas fees; the transaction is not authorized to access resources or code stored in the payer account.

📖 **[Authorizers](https://docs.onflow.org/concepts/transaction-signing/#signer-roles)** are accounts that authorize a transaction to read and mutate their resources. A transaction can specify zero or more authorizers, depending on how many accounts the transaction needs to access.

The number of authorizers on the transaction must match the number of AuthAccount parameters declared in the prepare statement of the Cadence script.

Example transaction with multiple authorizers:
```
transaction {
  prepare(authorizer1: AuthAccount, authorizer2: AuthAccount) { }
}
```

📖 **Gas limit** is the limit on the amount of computation a transaction requires, and it will abort if it exceeds its gas limit.
Cadence uses metering to measure the number of operations per transaction. You can read more about it in the [Cadence documentation](/cadence).

The gas limit depends on the complexity of the transaction script. Until dedicated gas estimation tooling exists, it's best to use the emulator to test complex transactions and determine a safe limit.

📖 **Reference block** specifies an expiration window (measured in blocks) during which a transaction is considered valid by the network.
A transaction will be rejected if it is submitted past its expiry block. Flow calculates transaction expiry using the _reference block_ field on a transaction.
A transaction expires after `600` blocks are committed on top of the reference block, which takes about 10 minutes at average Mainnet block rates.

### Build Transactions
Building a transaction involves setting the required properties explained above and producing a transaction object. 

Here we define a simple transaction script that will be used to execute on the network and serve as a good learning example.
Quick example of building a transaction:

```swift
let address = Flow.Address(hex: "0x1")
var unsignedTx = try! flow.buildTransaction{
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
        // SequenceNumber is optional. If it's nil, it will fetch the updated one from the chain.
        Flow.TransactionProposalKey(address: address, keyIndex: 1)
        
        // If you are using the key 0, you can just pass the address 
        // address
    }

    authorizers {
        address
    }

    arguments {
        .init(value: .string("Hello Flow!"))
    }
    
    // If payer is the same as proposer, you can ignore this field
    payer {
        address
    }

    // optional
    gasLimit {
        1000
    }
}
```

After you have successfully [built a transaction](#build-transactions) the next step in the process is to sign it.

### Sign Transactions
Flow introduces new concepts that allow for more flexibility when creating and signing transactions.
Before trying the examples below, we recommend that you read through the [transaction signature documentation](https://docs.onflow.org/concepts/accounts-and-keys/).

After you have successfully [built a transaction](#build-transactions) the next step in the process is to sign it. Flow transactions have envelope and payload signatures, and you should learn about each in the [signature documentation](https://docs.onflow.org/concepts/accounts-and-keys/#anatomy-of-a-transaction).


Signatures can be generated more securely using keys stored in a hardware device such as an [HSM](https://en.wikipedia.org/wiki/Hardware_security_module). The `crypto.Signer` interface is intended to be flexible enough to support a variety of signer implementations and is not limited to in-memory implementations.

To sign the transaction, you need create a list signer which confirm **FlowSigner** protocol. 
```swift
public protocol FlowSigner {
    var address: Flow.Address { get set }
    var keyIndex: Int { get set }
    func signature(signableData: Data) throws -> Data
}
```

Flow supports great flexibility when it comes to transaction signing, we can define multiple authorizers (multi-sig transactions) and have different payer account than proposer. We will explore advanced signing scenarios bellow.

### [Single party, single signature](https://docs.onflow.org/concepts/transaction-signing/#single-party-single-signature)

- Proposer, payer and authorizer are the same account (`0x01`).
- Only the envelope must be signed.
- Proposal key must have full signing weight.

| Account | Key ID | Weight |
| ------- | ------ | ------ |
| `0x01`  | 1      | 1.0    |

```swift
let address = Flow.Address("0x1")
let signers = [YourSigner(address: address, keyIndex: 1)]
do {
    var unsignedTx = try flow.buildTransaction{
        cadence {
            """
            transaction { 
                prepare(signer: AuthAccount) { log(signer.address) }
            }
            """
        }

        proposer {
            Flow.TransactionProposalKey(address: address, keyIndex: 1)
        }

        authorizers {
            address
        }
    }
    let signedTx = try unsignedTx.sign(signers: signers)
} catch {
    // Handle Error
}
```

### [Single party, multiple signatures](https://docs.onflow.org/concepts/transaction-signing/#single-party-multiple-signatures)

- Proposer, payer and authorizer are the same account (`0x01`).
- Only the envelope must be signed.
- Each key has weight 0.5, so two signatures are required.

| Account | Key ID | Weight |
| ------- | ------ | ------ |
| `0x01`  | 1      | 0.5    |
| `0x01`  | 2      | 0.5    |

```swift
let address = Flow.Address("0x1")
let signers = [YourSigner(address: address, keyIndex: 1), YourSigner(address: address, keyIndex: 2)]
do {
    var unsignedTx = try flow.buildTransaction{
        cadence {
            """
            transaction { 
                prepare(signer: AuthAccount) { log(signer.address) }
            }
            """
        }

        proposer {
            Flow.TransactionProposalKey(address: address, keyIndex: 1)
        }

        authorizers {
            address
        }
    }
    let signedTx = try unsignedTx.sign(signers: signers)
} catch {
    // Handle Error
}
```

### [Multiple parties](https://docs.onflow.org/concepts/transaction-signing/#multiple-parties)

- Proposer and authorizer are the same account (`0x01`).
- Payer is a separate account (`0x02`).
- Account `0x01` signs the payload.
- Account `0x02` signs the envelope.
    - Account `0x02` must sign last since it is the payer.

| Account | Key ID | Weight |
| ------- | ------ | ------ |
| `0x01`  | 1      | 1.0    |
| `0x02`  | 3      | 1.0    |

```swift
let addressA = Flow.Address("0x1")
let addressB = Flow.Address("0x2")
let signers = [YourSigner(address: addressA, keyIndex: 1), YourSigner(address: addressB, keyIndex: 3)]
do {
    var unsignedTx = try flow.buildTransaction{
        cadence {
            """
            transaction { 
                prepare(signer: AuthAccount) { log(signer.address) }
            }
            """
        }

        proposer {
            Flow.TransactionProposalKey(address: addressA, keyIndex: 1)
        }

        authorizers {
            addressA
        }
    }
    let signedTx = try unsignedTx.sign(signers: signers)
} catch {
    // Handle Error
}
```

### [Multiple parties, two authorizers](https://docs.onflow.org/concepts/transaction-signing/#multiple-parties)

- Proposer and authorizer are the same account (`0x01`).
- Payer is a separate account (`0x02`).
- Account `0x01` signs the payload.
- Account `0x02` signs the envelope.
    - Account `0x02` must sign last since it is the payer.
- Account `0x02` is also an authorizer to show how to include two AuthAccounts into an transaction

| Account | Key ID | Weight |
| ------- | ------ | ------ |
| `0x01`  | 1      | 1.0    |
| `0x02`  | 3      | 1.0    |

```swift
let addressA = Flow.Address("0x1")
let addressB = Flow.Address("0x2")
let signers = [YourSigner(address: addressA, keyIndex: 1), YourSigner(address: addressB, keyIndex: 3)]
do {
    var unsignedTx = try flow.buildTransaction{
        cadence {
            """
            transaction {
                prepare(signer1: AuthAccount, signer2: AuthAccount) {
                  log(signer.address)
                  log(signer2.address)
                }
            }
            """
        }

        proposer {
            Flow.TransactionProposalKey(address: addressA, keyIndex: 1)
        }

        authorizers {
            [addressA, addressB]
        }
    }
    let signedTx = try unsignedTx.sign(signers: signers)
} catch {
    // Handle Error
}
```

### [Multiple parties, multiple signatures](https://docs.onflow.org/concepts/transaction-signing/#multiple-parties)

- Proposer and authorizer are the same account (`0x01`).
- Payer is a separate account (`0x02`).
- Account `0x01` signs the payload.
- Account `0x02` signs the envelope.
    - Account `0x02` must sign last since it is the payer.
- Both accounts must sign twice (once with each of their keys).

| Account | Key ID | Weight |
| ------- | ------ | ------ |
| `0x01`  | 1      | 0.5    |
| `0x01`  | 2      | 0.5    |
| `0x02`  | 3      | 0.5    |
| `0x02`  | 4      | 0.5    |

```swift
let addressA = Flow.Address("0x1")
let addressB = Flow.Address("0x2")
let signers = [YourSigner(address: addressA, keyIndex: 1),
                YourSigner(address: addressA, keyIndex: 2), 
                YourSigner(address: addressB, keyIndex: 3),
                YourSigner(address: addressB, keyIndex: 4)]
do {
    var unsignedTx = try flow.buildTransaction{
        cadence {
            """
            transaction {
                prepare(signer1: AuthAccount, signer2: AuthAccount) {
                  log(signer.address)
                  log(signer2.address)
                }
            }
            """
        }

        proposer {
            Flow.TransactionProposalKey(address: addressA, keyIndex: 1)
        }

        authorizers {
            [addressA, addressB]
        }
        
        payer {
            addressB
        }
    }
    let signedTx = try unsignedTx.sign(signers: signers)
} catch {
    // Handle Error
}
```


### Send Transactions

After a transaction has been [built](#build-transactions) and [signed](#sign-transactions), it can be sent to the Flow blockchain where it will be executed. If sending was successful you can then [retrieve the transaction result](#get-transactions).

```swift
flow.sendTransaction(signedTrnaction: signedTx).whenComplete { result in
    switch result {
    case let .success(account):
        // Handle Success Result
    case let .failure(error):
        // Handle Error
    }
}
```


### Create Accounts

On Flow, account creation happens inside a transaction. Because the network allows for a many-to-many relationship between public keys and accounts, it's not possible to derive a new account address from a public key offline. 

The Flow VM uses a deterministic address generation algorithm to assigen account addresses on chain. You can find more details about address generation in the [accounts & keys documentation](https://docs.onflow.org/concepts/accounts-and-keys/).

#### Public Key
Flow uses ECDSA key pairs to control access to user accounts. Each key pair can be used in combination with the SHA2-256 or SHA3-256 hashing algorithms.

⚠️ You'll need to authorize at least one public key to control your new account.

Flow represents ECDSA public keys in raw form without additional metadata. Each key is a single byte slice containing a concatenation of its X and Y components in big-endian byte form.

A Flow account can contain zero (not possible to control) or more public keys, referred to as account keys. Read more about [accounts in the documentation](https://docs.onflow.org/concepts/accounts-and-keys/#accounts).

An account key contains the following data:
- Raw public key (described above)
- Signature algorithm
- Hash algorithm
- Weight (integer between 0-1000)

Account creation happens inside a transaction, which means that somebody must pay to submit that transaction to the network. We'll call this person the account creator. Make sure you have read [sending a transaction section](#send-transactions) first. 

```swift
let accountKey = Flow.AccountKey(publicKey: Flow.PublicKey(hex: "0x1"),
                                 signAlgo: .ECDSA_P256,
                                 hashAlgo: .SHA2_256,
                                 weight: 1000)

flow.createAccount(address: address, publicKeys: [accountKey], contracts: [scriptName: script], signers: signers)
.whenComplete { result in
    switch result {
    case let .success(account):
        // Handle Success Result
    case let .failure(error):
        // Handle Error
    }
}
```

After the account creation transaction has been submitted you can retrieve the new account address by [getting the transaction result](#get-transactions). 

The new account address will be emitted in a system-level `flow.AccountCreated` event.
```swift
let txID = flow.createAccount(address: address, publicKeys: [accountKey], contracts: [scriptName: script], signers: signers).wait()
let result = try! txID.onceSealed().wait()
let event = result.events.first{ $0.type == "flow.AccountCreated" }
let field = event?.payload.fields?.value.toEvent()?.fields.first{$0.name == "address"}
let address = field?.value.value.toAddress()?.hex
```

### Generate Keys

To generating the key, please check our another SDK - [Flow Wallet Kit](https://github.com/zed-io/flow-wallet-kit)
