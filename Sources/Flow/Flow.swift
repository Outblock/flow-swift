class Flow {
    static let shared = Flow()

    var defaultChainId = FlowChainId.mainnet

    var addressRegistry = AddressRegistry()
}
