import FlowStakingCollection from 0xFlowStakingCollection
import FlowIDTableStaking from 0xFlowIDTableStaking
import LockedTokens from 0xLockedTokens
        
access(all) fun main(address: Address): [FlowIDTableStaking.DelegatorInfo]? {
    var res: [FlowIDTableStaking.DelegatorInfo]? = nil

    let inited = FlowStakingCollection.doesAccountHaveStakingCollection(address: address)

    if inited {
        res = FlowStakingCollection.getAllDelegatorInfo(address: address)
    }
    return res
}
