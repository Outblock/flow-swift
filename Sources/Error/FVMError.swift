//
//  FVMError.swift
//  Flow
//
//  Created by Hao Fu on 31/10/2024.
//

import Foundation

enum FvmErrorCode: Int, CaseIterable {
    // We use -1 for unknown error in FCL because FVM defines error codes as uint16
    // This means we have no risk of collision with FVM error codes
    case unknownError = -1

    // tx validation errors 1000 - 1049
    // Deprecated: no longer in use
    case txValidationError = 1000
    // Deprecated: No longer used.
    case invalidTxByteSizeError = 1001
    // Deprecated: No longer used.
    case invalidReferenceBlockError = 1002
    // Deprecated: No longer used.
    case expiredTransactionError = 1003
    // Deprecated: No longer used.
    case invalidScriptError = 1004
    // Deprecated: No longer used.
    case invalidGasLimitError = 1005
    case invalidProposalSignatureError = 1006
    case invalidProposalSeqNumberError = 1007
    case invalidPayloadSignatureError = 1008
    case invalidEnvelopeSignatureError = 1009

    // base errors 1050 - 1100
    // Deprecated: No longer used.
    case fvmInternalError = 1050
    case valueError = 1051
    case invalidArgumentError = 1052
    case invalidAddressError = 1053
    case invalidLocationError = 1054
    case accountAuthorizationError = 1055
    case operationAuthorizationError = 1056
    case operationNotSupportedError = 1057
    case blockHeightOutOfRangeError = 1058

    // execution errors 1100 - 1200
    // Deprecated: No longer used.
    case executionError = 1100
    case cadenceRuntimeError = 1101
    // Deprecated: No longer used.
    case encodingUnsupportedValue = 1102
    case storageCapacityExceeded = 1103
    // Deprecated: No longer used.
    case gasLimitExceededError = 1104
    case eventLimitExceededError = 1105
    case ledgerInteractionLimitExceededError = 1106
    case stateKeySizeLimitError = 1107
    case stateValueSizeLimitError = 1108
    case transactionFeeDeductionFailedError = 1109
    case computationLimitExceededError = 1110
    case memoryLimitExceededError = 1111
    case couldNotDecodeExecutionParameterFromState = 1112
    case scriptExecutionTimedOutError = 1113
    case scriptExecutionCancelledError = 1114
    case eventEncodingError = 1115
    case invalidInternalStateAccessError = 1116
    // 1117 was never deployed and is free to use
    case insufficientPayerBalance = 1118

    // accounts errors 1200 - 1250
    // Deprecated: No longer used.
    case accountError = 1200
    case accountNotFoundError = 1201
    case accountPublicKeyNotFoundError = 1202
    case accountAlreadyExistsError = 1203
    // Deprecated: No longer used.
    case frozenAccountError = 1204
    // Deprecated: No longer used.
    case accountStorageNotInitializedError = 1205
    case accountPublicKeyLimitError = 1206

    // contract errors 1250 - 1300
    // Deprecated: No longer used.
    case contractError = 1250
    case contractNotFoundError = 1251
    // Deprecated: No longer used.
    case contractNamesNotFoundError = 1252

    // fvm std lib errors 1300-1400
    case evmExecutionError = 1300
    
    var errorTag: String {
        "[Error Code: \(String(self.rawValue))]" 
    }
}
