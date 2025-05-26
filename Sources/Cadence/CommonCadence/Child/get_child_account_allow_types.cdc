import HybridCustody from 0xHybridCustody
import NonFungibleToken from 0xNonFungibleToken
import FungibleToken from 0xFungibleToken


// This script iterates through a parent's child accounts,
// identifies private paths with an accessible NonFungibleToken.Provider, and returns the corresponding typeIds
access(all) fun main(addr: Address, child: Address): [String]? {
  let account = getAuthAccount<auth(Storage) &Account>(addr)
  let manager = getAuthAccount<auth(Storage) &Account>(addr).storage.borrow<auth(HybridCustody.Manage) &HybridCustody.Manager>(from: HybridCustody.ManagerStoragePath) ?? panic ("manager does not exist")


  
  let nftProviderType = Type<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Provider}>()
  let ftProviderType = Type<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>()

  // Iterate through child accounts
  let addr = getAuthAccount<auth(Storage, Capabilities) &Account>(child)
  let foundTypes: [String] = []
  let childAcct = manager.borrowAccount(addr: child) ?? panic("child account not found")
  // get all private paths

  for s in addr.storage.storagePaths {
    let controllers = addr.capabilities.storage.getControllers(forPath: s)
    for c in controllers {
      // if !c.borrowType.isSubtype(of: providerType) {
      //   continue
      // }

      if let nftCap = childAcct.getCapability(controllerID: c.capabilityID, type: nftProviderType) {
        let providerCap = nftCap as! Capability<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Provider}>

        if !providerCap.check(){
          continue
        }

        foundTypes.append(nftCap.borrow<&AnyResource>()!.getType().identifier)
        break
      }
      if let ftCap = childAcct.getCapability(controllerID: c.capabilityID, type: ftProviderType) {
        let providerCap = ftCap as! Capability<&{FungibleToken.Provider}>

        if !providerCap.check(){
          continue
        }

        foundTypes.append(ftCap.borrow<&AnyResource>()!.getType().identifier)
        break
      }
    }
  }

  return foundTypes
}
