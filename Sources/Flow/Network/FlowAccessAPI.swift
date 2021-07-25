//
//  File.swift
//  
//
//  Created by lmcmz on 25/7/21.
//

import Foundation
import GRPC
import SwiftProtobuf
import NIO

class FlowAccessAPI {
    
    var client: ClientConnection
    var APIClient: Flow_Access_AccessAPIClient
    
    init(config: ClientConnection.Configuration) {
        client = ClientConnection(configuration: config)
        APIClient = Flow_Access_AccessAPIClient(channel: client)
    }
    
    // MARK: - Implementation
    
    func ping() -> EventLoopFuture<Flow_Access_PingResponse> {
        let test = APIClient.ping( Flow_Access_PingRequest() )
        return test.response
    }
}
