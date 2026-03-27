// get_addr.cdc (Cadence 1.0, normalized optionals and loops)

import EVM from 0xEVM

access(all) fun main(flowAddress: Address): String? {
    let acct = getAuthAccount<auth(BorrowValue) &Account>(flowAddress)

    if let addressRef = acct.storage.borrow<&EVM.CadenceOwnedAccount>(
        from: /storage/evm
    ) {
        let address: EVM.EVMAddress = addressRef.address()

        let bytes: [UInt8] = []
        for byte in address.bytes {
            bytes.append(byte)
        }

        return String.encodeHex(bytes)
    }

    return nil
}
