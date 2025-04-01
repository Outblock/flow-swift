access(all) 
struct StorageInfo {
    access(all) let capacity: UInt64
    access(all) let used: UInt64
    access(all) let available: UInt64

    init(capacity: UInt64, used: UInt64, available: UInt64) {
        self.capacity = capacity
        self.used = used
        self.available = available
    }
}

access(all) fun main(addr: Address): StorageInfo {
    let acct: &Account = getAccount(addr)
    return StorageInfo(capacity: acct.storageCapacity,
                      used: acct.storageUsed,
                      available: acct.storageCapacity - acct.storageUsed)
} 