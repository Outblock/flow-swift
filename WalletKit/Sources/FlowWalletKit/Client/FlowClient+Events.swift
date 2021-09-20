import Foundation

extension FlowClient {
    public func getEventsForHeightRange(type: String, start: Int = 0, end: Int = 0, completion: @escaping (ResultCallback)) {
        var queryStart = start
        var queryEnd = end
        if end == 0, start == 0 {
            return
        } else if end == 0 {
            queryEnd = start + 249
        } else if start == 0 {
            queryStart = end - 249
        }

        rpcProvider.getEventsForHeightRange(type: type, start: queryStart, end: queryEnd, completion: completion)
    }

    public func getEventsForBlockIds(type: String, blockIds: [FlowIdentifier], completion: @escaping (ResultCallback)) {
        rpcProvider.getEventsForBlockIds(type: type, blockIds: blockIds, completion: completion)
    }
}
