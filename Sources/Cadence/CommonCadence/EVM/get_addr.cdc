import EVM from 0xEVM

access(all) fun main(flowAddress: Address): String? {
    if let address: EVM.EVMAddress = getAuthAccount<auth(BorrowValue) &Account>(flowAddress)
        .storage.borrow<&EVM.CadenceOwnedAccount>(from: /storage/evm)?.address() {
        let bytes: [UInt8] = []
        for byte in address.bytes {
            bytes.append(byte)
        }
        return String.encodeHex(bytes)
    }
    return nil
}