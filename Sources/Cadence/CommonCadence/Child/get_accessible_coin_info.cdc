import HybridCustody from 0xHybridCustody
import MetadataViews from 0xMetadataViews
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken


access(all) struct TokenInfo {
access(all) let id: String
access(all) let balance: UFix64

init(id: String, balance: UFix64) {
    self.id = id
    self.balance = balance
}
}

access(all) fun main(parent: Address, childAddress: Address): [TokenInfo] {
    let manager = getAuthAccount<auth(Storage) &Account>(parent).storage.borrow<auth(HybridCustody.Manage) &HybridCustody.Manager>(from: HybridCustody.ManagerStoragePath) ?? panic ("manager does not exist")

    var typeIdsWithProvider: {Address: [String]} = {}

    var coinInfoList: [TokenInfo] = []
    let providerType = Type<Capability<&{FungibleToken.Provider}>>()
    let vaultType: Type = Type<@{FungibleToken.Vault}>()

    // Iterate through child accounts

    let acct = getAuthAccount<auth(Storage, Capabilities) &Account> (childAddress)
    let foundTypes: [String] = []
    let vaultBalances: {String: UFix64} = {}
    let childAcct = manager.borrowAccount(addr: childAddress) ?? panic("child account not found")
    // get all private paths
    acct.storage.forEachStored(fun (path: StoragePath, type: Type): Bool {
        // Check which private paths have NFT Provider AND can be borrowed
        if !type.isSubtype(of: providerType){
            return true
        }

        let controllers = acct.capabilities.storage.getControllers(forPath: path)

        // let providerCap = cap as! Capability<&{FungibleToken.Provider}>

        for c in controllers {
            if !c.borrowType.isSubtype(of: providerType) {
                continue
            }

            if let cap = childAcct.getCapability(controllerID: c.capabilityID, type: providerType) {
                let providerCap = cap as! Capability<&{NonFungibleToken.Provider}>

                if !providerCap.check(){
                    continue
                }
                foundTypes.append(cap.borrow<&AnyResource>()!.getType().identifier)
            }
        }
        return true
    })
    typeIdsWithProvider[childAddress] = foundTypes

    
    acct.storage.forEachStored(fun (path: StoragePath, type: Type): Bool {
    
    if typeIdsWithProvider[childAddress] == nil {
        return true
    }

    for key in typeIdsWithProvider.keys {
        for idx, value in typeIdsWithProvider[key]! {
            let value = typeIdsWithProvider[key]!

            if value[idx] != type.identifier {
                continue
            } else {
                if type.isInstance(vaultType) {
                continue
                }
                if let vault = acct.storage.borrow<&{FungibleToken.Balance}>(from: path) {
                // Iterate over IDs & resolve the view
                    coinInfoList.append(
                    TokenInfo(id: type.identifier, balance: vault.balance))
                }
                continue
            }
        }
        }
      return true
    })

    
    return coinInfoList
}
