// get_child_account_meta.cdc

import HybridCustody from 0xHybridCustody
import MetadataViews from 0xMetadataViews

access(all) fun main(parent: Address): {Address: AnyStruct} {
    let acct = getAuthAccount<auth(Storage) &Account>(parent)
    let managerRef = acct.storage.borrow<&HybridCustody.Manager>(
        from: HybridCustody.ManagerStoragePath
    )

    if managerRef == nil {
        return {}
    }

    var  {Address: AnyStruct} = {}

    for address in managerRef!.getChildAddresses() {
        let display = managerRef!.getChildAccountDisplay(address: address)
        data.insert(key: address, display)
    }

    return data
}
