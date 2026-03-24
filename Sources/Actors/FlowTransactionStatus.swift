//
//  FlowTransaction.swift
//  Flow
//
//  Created by Nicholas Reich on 3/23/26.
//
public extension Flow {
		/// Backwards compatibility bridge: use `Flow.Transaction.Status` everywhere,
		/// but expose it as `Flow.TransactionStatus` for older APIs.
	typealias TransactionStatus = Transaction.Status
}

