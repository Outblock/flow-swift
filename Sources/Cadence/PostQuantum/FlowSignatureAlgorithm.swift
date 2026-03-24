//
//  FlowSignatureAlgorithm.swift
//  Flow
//
//  Created by Nicholas Reich on 3/21/26.
//


public enum FlowSignatureAlgorithm: Sendable {
    case ecdsaP256
    case ecdsaSecp256k1
    case mlDsaHybrid // classical + PQC
}
