<p align="center">
  <img src="https://img.shields.io/github/v/release/ryankopinsky/flow-swift-sdk?color=orange&label=SwiftPM&logo=swift"/>
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS-lightgrey"/>
  <img src="https://img.shields.io/badge/Swift-5.3-orange?logo=swift"/>
  <img src="https://img.shields.io/github/license/ryankopinsky/flow-swift-sdk"/>
</p>

# Flow Swift SDK
The Flow Swift SDK is a Swift gRPC client for Flow (https://www.onflow.org). 

Currently the following Flow Access API methods have been implemented:

### Connection
- [x] Ping

### Accounts
- [x] GetAccountAtLatestBlock
- [x] GetAccountAtBlockHeight

### Blocks
- [x] GetLatestBlock
- [x] GetBlockByHeight

### Events
- [x] GetEventsForHeightRange

### Scripts
- [x] ExecuteScriptAtLatestBlock
- [x] ExecuteScriptAtBlockHeight

## Installation

This is a Swift Package, and can be installed via Xcode with the URL of this repository:

`https://github.com/ryankopinsky/flow-swift-sdk`

[For more information on how to add a Swift Package using Xcode, see Apple's official documentation.](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)


## Usage

```swift
// Connect to the Flow blockchain
let client = FlowClient(host: "access.mainnet.nodes.onflow.org", port: 9000)
client.ping { error in
    if let error = error {
        print("Ping Error: \(error.localizedDescription)")
    } else {
        print("Ping Success!")
    }
}
```

### Accounts

```swift
// Get account balance
let accountAddress = "0xead892083b3e2c6c" // Random address on mainnet
client.getAccount(address: accountAddress) { account, error in
    guard let account = account else {
        print("Error getAccount: \(error!.localizedDescription)")
        return
    }
    
    print("Account with address \(accountAddress) has balance \(account.balance).")
}
```

### Scripts

```swift
// Execute sample script
let script = "pub fun main(): Int { return 1 }".data(using: .utf8)!
client.executeScript(script: script, arguments: []) { jsonData, error in
    guard let jsonData = jsonData else {
        print("Error executeScript: \(error!.localizedDescription)")
        return
    }
    
    print("executeScript - resultType: \(String(describing: jsonData["type"])), resultValue: \(String(describing: jsonData["value"])).")
}
```

Note: not all functionality is demonstrated in the above examples. To explore the capabilities of the Flow Swift SDK, feel free to check out the Tests folder. Most functionality will have a corresponding test case. 

## Contributing

Contributions (such as feature requests, bug reports, pull requests etc) are welcome and encouraged. Make sure to abide by the [Code of Conduct](https://github.com/ryankopinsky/flow-swift-sdk/blob/main/CODE_OF_CONDUCT.md). 
