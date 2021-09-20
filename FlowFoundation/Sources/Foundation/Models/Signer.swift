//
//  Signer.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

extension Flow {
    struct PublicKey: FlowEntity, Equatable {
        var data: Data

        init(hex: String) {
            data = hex.hexValue.data
        }

        init(data: Data) {
            self.data = data
        }

        init(bytes: [UInt8]) {
            data = bytes.data
        }
    }

    struct Code: FlowEntity, Equatable {
        var data: Data
    }
}
