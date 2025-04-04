import FungibleToken from 0xFungibleToken

/// Queries for FT.Vault balance of all FT.Vaults in the specified account.
///
access(all) fun main(address: Address): {String: UFix64} {
    // Get the account
    let account = getAuthAccount<auth(BorrowValue) &Account>(address)
    // Init for return value
    let balances: {String: UFix64} = {}
    // Track seen Types in array
    let seen: [String] = []
    // Assign the type we'll need
    let vaultType: Type = Type<@{FungibleToken.Vault}>()
    // Iterate over all stored items & get the path if the type is what we're looking for
    account.storage.forEachStored(fun (path: StoragePath, type: Type): Bool {
        if !type.isRecovered && (type.isInstance(vaultType) || type.isSubtype(of: vaultType)) {
            // Get a reference to the resource & its balance
            let vaultRef = account.storage.borrow<&{FungibleToken.Balance}>(from: path)!
            // Insert a new values if it's the first time we've seen the type
            if !seen.contains(type.identifier) {
                balances.insert(key: type.identifier, vaultRef.balance)
            } else {
                // Otherwise just update the balance of the vault (unlikely we'll see the same type twice in
                // the same account, but we want to cover the case)
                balances[type.identifier] = balances[type.identifier]! + vaultRef.balance
            }
        }
        return true
    })

    // Add available Flow Token Balance
    balances.insert(key: "availableFlowToken", account.availableBalance)

    return balances
}