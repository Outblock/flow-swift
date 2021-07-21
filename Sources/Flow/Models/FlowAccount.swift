//
//  File.swift
//  
//
//  Created by lmcmz on 21/7/21.
//

import Foundation
import BigInt

struct FlowAccount {
    let address: FlowAddress
    let balance: BigInt
    var keys: [FlowAccountKey]
    
//    init(value: Flow_Entities_Account) {
//        address = FlowAddress(bytes: value.address.byteArray)
//    }
}


struct FlowAccountKey {
    let id: Int = -1
//    let publicKey: FlowPublicKey
    let signAlgo: SignatureAlgorithm
    let hashAlgo: HashAlgorithm
    let weight: Int
    let sequenceNumber: Int = -1
    let revoked: Bool = false
}

