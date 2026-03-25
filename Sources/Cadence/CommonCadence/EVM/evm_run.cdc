// transfer_to_evm.cdc (your EVM bridge tx, updated & normalized)

import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import EVM from 0xEVM

/// Transfers $FLOW from the signer's Cadence Flow balance to the recipient's
/// hex-encoded EVM address. The COA must already have $FLOW bridged into EVM.
transaction(
    toEVMAddressHex: String,
    amount: UFix64,
     [UInt8],
    gasLimit: UInt64
) {

    let coa: auth(EVM.Withdraw, EVM.Call) &EVM.CadenceOwnedAccount
    let recipientEVMAddress: EVM.EVMAddress

    prepare(signer: auth(BorrowValue, SaveValue) &Account) {
        if signer.storage.type(at: /storage/evm) == nil {
            signer.storage.save(<-EVM.createCadenceOwnedAccount(), to: /storage/evm)
        }

        self.coa = signer.storage.borrow<
            auth(EVM.Withdraw, EVM.Call) &EVM.CadenceOwnedAccount
        >(from: /storage/evm)
            ?? panic("Could not borrow reference to the signer's bridged account")

        self.recipientEVMAddress = EVM.addressFromString(toEVMAddressHex)
    }

    execute {
        // No-op if sending to self.
        if self.recipientEVMAddress.bytes == self.coa.address().bytes {
            return
        }

        let valueBalance = EVM.Balance(attoflow: 0)
        valueBalance.setFLOW(flow: amount)

        let txResult = self.coa.call(
            to: self.recipientEVMAddress,
             data,
            gasLimit: gasLimit,
            value: valueBalance
        )

        assert(
            txResult.status == EVM.Status.failed
                || txResult.status == EVM.Status.successful,
            message:
                "evm_error="
                .concat(txResult.errorMessage)
                .concat("\n")
        )
    }
}
