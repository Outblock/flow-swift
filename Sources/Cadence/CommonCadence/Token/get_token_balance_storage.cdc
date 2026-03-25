import FungibleToken from 0xFungibleToken

/// Queries FT.Vault balances for all FT vaults in the specified account.
access(all) fun main(address: Address): {String: UFix64} {
    // Get the account with borrow access.
    let account = getAuthAccount<auth(BorrowValue) &Account>(address)

    // Init for return value.
    let balances: {String: UFix64} = {}

    // Track seen type identifiers.
    let seen: [String] = []

    // The type to match against.
    let vaultType: Type = Type<@{FungibleToken.Vault}>()

    // Iterate over all stored items & get the path if the type is what we're looking for.
    account.storage.forEachStored(fun (path: StoragePath, storedType: Type): Bool {
        if !storedType.isRecovered &&
           (storedType.isInstance(vaultType) || storedType.isSubtype(of: vaultType)) {

            // Get a reference to the resource & its balance.
            let vaultRef = account.storage.borrow<&{FungibleToken.Balance}>(from: path)
                ?? panic("Could not borrow FT.Balance reference at path ".concat(path.toString()))

            // Insert a new value if it's the first time we've seen the type.
            if !seen.contains(storedType.identifier) {
                balances.insert(key: storedType.identifier, vaultRef.balance)
            } else {
                // Otherwise update the balance of the vault (covers multiple vaults of same type).
                balances[storedType.identifier] = balances[storedType.identifier]! + vaultRef.balance
            }
        }
        return true
    })

    // Add available Flow Token balance.
    balances.insert(key: "availableFlowToken", account.availableBalance)

    return balances
}
