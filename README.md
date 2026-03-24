```markdown
# flow-swift (Swift 6 & Swift Testing Migration)

This fork updates the original Outblock `flow-swift` SDK and tests for Swift 6, modern concurrency, and Swift Testing. It focuses on safety, test reliability, and compatibility with current Flow tooling and APIs.

## What’s New

### 1. Swift 6 Concurrency & Actors

- Actor-based WebSocket center  
  - Introduced a WebSocket coordination actor that manages NIO-based subscriptions for transaction status streams.  
  - Uses `AsyncThrowingStream<Flow.WebSocketTopicResponse<Flow.WSTransactionResponse>, Error>.Continuation` per `Flow.ID` to bridge NIO callbacks into structured async streams.

- Transaction status waiting APIs  
  - Added helpers like:
    - `once(status: Flow.Transaction.Status, timeout: TimeInterval = 60) async throws -> Flow.TransactionResult` on `Flow.ID`.  
  - Internally, this uses `AsyncThrowingStream` and task groups to:
    - Listen for WebSocket updates.
    - Enforce timeouts.
    - Cancel remaining work after a result is obtained.

- Sendable coverage  
  - Marked core models as `Sendable` where correct, including:
    - Transaction-related WebSocket response types.
    - Value and argument container types used across tasks and actors.

### 2. Swift Testing Migration

All XCTest-based tests were migrated to the new Swift Testing APIs:

- `@Suite` instead of `XCTestCase`.
- `@Test("description")` instead of `func testXYZ()`.
- `#expect(...)` assertions instead of `XCTAssert*`.

Updated suites include (non-exhaustive):

- `FlowAccessAPIOnTestnetTests`
- `FlowOperationTests` (with legacy examples preserved but disabled)
- `CadenceTargetTests`
- `RLPTests`

### 3. API & DSL Adjustments

- Transaction builder DSL  
  - Transaction construction now uses a clearer builder style:
    - `cadence { """ ... """ }`
    - `proposer { Flow.TransactionProposalKey(...) }`
    - `payer { Flow.Address(...) }`
    - `authorizers { [...] }`
    - `arguments { [Flow.Argument(...), ...] }`
    - `gasLimit { 1000 }`
  - Builders are compatible with Swift 6’s stricter closure isolation rules.

- Flow.Argument & Cadence values  
  - `Flow.Argument` retains initializers that wrap Cadence values, while avoiding leaking internal representation types into the public API.  
  - Conversion helpers are available internally to map between Cadence values and arguments, but callers typically work directly with `Flow.Argument` and the DSL.

- Cadence target tests  
  - `CadenceTargetTests` now uses an explicit enum-based target description without relying on reflection.  
  - Arguments are explicitly constructed per case, improving clarity and type safety.

### 4. Access Control & Safety Tightening

- Cadence model types and conversion utilities remain internal to the SDK, so they do not appear in the public API.  
- Helpers that depend on internal representation types are kept internal to avoid access-control and ABI issues.  
- Public surface area exposes stable, high-level types (e.g., `Flow.Argument`, `Flow.Address`, `Flow.Transaction`) instead of low-level Cadence internals.

### 5. RLP & Transaction Encoding Tests

- `RLPTests` were modernized for Swift 6:
  - Fixed issues where mutating helpers were called on immutable values by introducing local mutable copies when necessary.
  - Preserved all original RLP expectations, ensuring transaction encoding remains compatible with Flow nodes.

## What Was Removed or Disabled

- Legacy high-level transaction helpers on `Flow`  
  - Methods like `addContractToAccount`, `removeAccountKeyByIndex`, `addKeyToAccount`, `createAccount(...)`, `updateContractOfAccount`, `removeContractFromAccount`, and `verifyUserSignature(...)` are no longer exposed on the main `Flow` type.  
  - Tests that referenced these helpers have been converted into commented examples inside `FlowOperationTests`:
    - They remain as documentation for how to implement these flows.
    - They can be reintroduced or reimplemented using the new transaction builder DSL as needed.

- Reflection-based test plumbing  
  - Reflection-based helper types previously used to derive arguments (e.g., via `Mirror`) are no longer used in public-facing tests.  
  - Tests now wire arguments explicitly for clarity and compatibility with Swift 6.

## Installation

### Requirements

- Swift 6 toolchain (or the latest Swift that supports Swift Testing and stricter concurrency checks).  
- macOS with Xcode 16+ (or a matching Swift toolchain on another platform).  
- Network access to Flow testnet/mainnet for integration tests.

### Using Swift Package Manager

Add the package to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/<your-org>/flow-swift.git", branch: "main")
]
```

Then add `Flow` as a dependency to your target:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "Flow", package: "flow-swift")
    ]
)
```

Update and build:

```bash
swift package update
swift build
```

## Testing

This repository uses Swift Testing (`@Suite`, `@Test`, `#expect`) instead of XCTest.

### Run All Tests

From the package root:

```bash
swift test
```

This will build and run all active test suites, including:

- `FlowAccessAPIOnTestnetTests`
- `CadenceTargetTests`
- `RLPTests`
- `FlowOperationTests` (only active tests; legacy examples remain commented out)

### Network-dependent Tests

- `FlowAccessAPIOnTestnetTests` exercises real Flow access nodes against testnet.  
- Ensure:
  - Correct access node configuration (HTTP endpoint via `createHTTPAccessAPI(chainID: .testnet)`).
  - Stable network connectivity.

If you need to avoid network tests (e.g., in CI):

- Disable or tag specific tests/suites.
- Or temporarily comment out the `@Test` attributes for integration tests.

### Run a Single Suite

If your toolchain supports filtering:

```bash
swift test --filter FlowAccessAPIOnTestnetTests
```

## Notes for Contributors

- Concurrency  
  - Prefer `actor` for shared mutable state (e.g., WebSocket centers).  
  - Only mark types as `Sendable` when they are truly safe across tasks.  
  - Avoid capturing non-Sendable types (such as test suites) in `@Sendable` closures; capture only the values needed.

- Access control  
  - Keep Cadence internals (`FValue`-like types and converters) non-public.  
  - When adding helpers on top of internal types, keep them internal unless you design a stable public abstraction.

- Tests as specification  
  - Encoding tests (especially RLP) serve as a compatibility spec; do not change expected hex outputs unless you are intentionally changing encoding semantics and understand the implications for network compatibility.
```

\
