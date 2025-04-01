import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import EVM from 0xEVM

/// Transfers $FLOW from the signer's account Cadence Flow balance to the recipient's hex-encoded EVM address.
/// Note that a COA must have a $FLOW balance in EVM before transferring value to another EVM address.
///
transaction(toEVMAddressHex: String, amount: UFix64, data: [UInt8], gasLimit: UInt64) {

    let coa: auth(EVM.Withdraw, EVM.Call) &EVM.CadenceOwnedAccount
    let recipientEVMAddress: EVM.EVMAddress

    prepare(signer: auth(BorrowValue, SaveValue) &Account) {
        if signer.storage.type(at: /storage/evm) == nil {
            signer.storage.save(<-EVM.createCadenceOwnedAccount(), to: /storage/evm)
        }
        self.coa = signer.storage.borrow<auth(EVM.Withdraw, EVM.Call) &EVM.CadenceOwnedAccount>(from: /storage/evm)
            ?? panic("Could not borrow reference to the signer's bridged account")

        self.recipientEVMAddress = EVM.addressFromString(toEVMAddressHex)
    }

    execute {
        if self.recipientEVMAddress.bytes == self.coa.address().bytes {
            return
        }
        let valueBalance = EVM.Balance(attoflow: 0)
        valueBalance.setFLOW(flow: amount)
        let txResult = self.coa.call(
            to: self.recipientEVMAddress,
            data: data,
            gasLimit: gasLimit,
            value: valueBalance
        )
        assert(
            txResult.status == EVM.Status.failed || txResult.status == EVM.Status.successful,
            message: "evm_error=".concat(txResult.errorMessage).concat("\n")
        )
    }
}