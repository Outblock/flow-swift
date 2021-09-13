import BigInt
@testable import Flow
import XCTest

final class RLPTests: XCTestCase {
    let prefix = "FLOW-V0.0-transaction".data(using: .utf8)!.byteArray.paddingZeroRight(blockSize: 32).hexValue
    let baseTx = Flow.Transaction(script: Flow.Script(script: "transaction { execute { log(\"Hello, World!\") } }"),
                                  arguments: [],
                                  referenceBlockId: Flow.Id(hex: "f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b"),
                                  gasLimit: BigUInt(42),
                                  proposalKey: Flow.TransactionProposalKey(address: Flow.Address(hex: "01"),
                                                                           keyIndex: 4,
                                                                           sequenceNumber: 10),
                                  payerAddress: Flow.Address(hex: "01"),
                                  authorizers: [Flow.Address(hex: "01")],
                                  payloadSignatures: [
                                      Flow.TransactionSignature(address: Flow.Address(hex: "01"),
                                                                signerIndex: 4,
                                                                keyIndex: 4,
                                                                signature: Flow.Signature(hex: "f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162")),
                                  ],
                                  envelopeSignatures: [])

    override func setUp() {
        super.setUp()
    }

    func testEmptyPayloadSigs() {
        let tx = baseTx.buildUpOn(payloadSignatures: [])
        guard let data = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }
        XCTAssertEqual(prefix + data.hexValue, "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f875f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001c0")
    }

    func testZeroPayloadSigsKey() {
        let tx = baseTx.buildUpOn(payloadSignatures: [baseTx.payloadSignatures.first!.buildUpon(keyIndex: 0)])
        guard let data = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }
        XCTAssertEqual(prefix + data.hexValue, "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001e4e38080a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162")
    }

    func testOutOfOrderBySinger() {
        let tx = baseTx.buildUpOn(
            authorizers: [Flow.Address(hex: "01"), Flow.Address(hex: "02"), Flow.Address(hex: "03")],
            payloadSignatures: [Flow.TransactionSignature(address: Flow.Address(hex: "03"),
                                                          signerIndex: 0,
                                                          keyIndex: 0,
                                                          signature: Flow.Signature(hex: "c")),
                                Flow.TransactionSignature(address: Flow.Address(hex: "01"),
                                                          signerIndex: 0,
                                                          keyIndex: 0,
                                                          signature: Flow.Signature(hex: "a")),
                                Flow.TransactionSignature(address: Flow.Address(hex: "02"),
                                                          signerIndex: 0,
                                                          keyIndex: 0,
                                                          signature: Flow.Signature(hex: "b"))]
        )
        guard let data = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + data.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f893f884b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001db880000000000000001880000000000000002880000000000000003ccc3808080c3018080c3028080")
    }

    func testOutOfOrderByKey() {
        let tx = baseTx.buildUpOn(
            authorizers: [Flow.Address(hex: "01")],
            payloadSignatures: [Flow.TransactionSignature(address: Flow.Address(hex: "01"),
                                                          signerIndex: 2,
                                                          keyIndex: 2,
                                                          signature: Flow.Signature(hex: "c")),
                                Flow.TransactionSignature(address: Flow.Address(hex: "01"),
                                                          signerIndex: 0,
                                                          keyIndex: 0,
                                                          signature: Flow.Signature(hex: "a")),
                                Flow.TransactionSignature(address: Flow.Address(hex: "01"),
                                                          signerIndex: 1,
                                                          keyIndex: 1,
                                                          signature: Flow.Signature(hex: "b"))]
        )
        guard let data = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + data.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f881f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001ccc3808080c3800180c3800280")
    }

    func testCompleteTx() {
        guard let encodedPayload = baseTx.encodedPayload else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedPayload.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001")

        guard let encodedEnvelope = baseTx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedEnvelope.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162")
    }

    func testEmptyCadence() {
        let tx = baseTx.buildUpOn(script: Flow.Script(script: ""))
        guard let encodedPayload = tx.encodedPayload else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedPayload.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f84280c0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001")

        guard let encodedEnvelope = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedEnvelope.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f869f84280c0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162")
    }

    func testNilRefBlock() {
        let tx = baseTx.buildUpOn(referenceBlockId: Flow.Id(hex: ""))
        guard let encodedPayload = tx.encodedPayload else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedPayload.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a000000000000000000000000000000000000000000000000000000000000000002a880000000000000001040a880000000000000001c9880000000000000001")

        guard let encodedEnvelope = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedEnvelope.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a000000000000000000000000000000000000000000000000000000000000000002a880000000000000001040a880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162")
    }

    func testZeroComputeLimit() {
        let tx = baseTx.buildUpOn(gasLimit: 0)
        guard let encodedPayload = tx.encodedPayload else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedPayload.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b80880000000000000001040a880000000000000001c9880000000000000001")

        guard let encodedEnvelope = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedEnvelope.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b80880000000000000001040a880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162")
    }

    func testZeroProposalKey() {
        let tx = baseTx.buildUpOn(proposalKey: Flow.TransactionProposalKey(address: Flow.Address(hex: "01"),
                                                                           keyIndex: 0,
                                                                           sequenceNumber: 10))
        guard let encodedPayload = tx.encodedPayload else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedPayload.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001800a880000000000000001c9880000000000000001")

        guard let encodedEnvelope = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedEnvelope.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001800a880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162")
    }

    func testZeroSequenceNumber() {
        let tx = baseTx.buildUpOn(proposalKey: Flow.TransactionProposalKey(address: Flow.Address(hex: "01"),
                                                                           keyIndex: 4,
                                                                           sequenceNumber: 0))
        guard let encodedPayload = tx.encodedPayload else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedPayload.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a8800000000000000010480880000000000000001c9880000000000000001")

        guard let encodedEnvelope = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedEnvelope.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a8800000000000000010480880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162")
    }

    func testEmptyAuthorizers() {
        let tx = baseTx.buildUpOn(authorizers: [])
        guard let encodedPayload = tx.encodedPayload else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedPayload.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f869b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c0")

        guard let encodedEnvelope = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedEnvelope.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f890f869b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c0e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162")
    }

    func testMultipleAuthorizers() {
        let tx = baseTx.buildUpOn(authorizers: [Flow.Address(hex: "01"), Flow.Address(hex: "02")])
        guard let encodedPayload = tx.encodedPayload else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedPayload.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f87bb07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001d2880000000000000001880000000000000002")

        guard let encodedEnvelope = tx.encodedEnvelope else {
            XCTFail("RLP encode error")
            return
        }

        XCTAssertEqual(prefix + encodedEnvelope.hexValue,
                       "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f8a2f87bb07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001d2880000000000000001880000000000000002e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162")
    }
}
