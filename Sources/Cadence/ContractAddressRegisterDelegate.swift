	//
	//  ContractAddressRegisterDelegate.swift
	//  Flow
	//
	//  Created by Hao Fu on 16/4/2025.
	//  Reviewed by Nicholas Reich on 2026-03-19.
	//

import Foundation

protocol CadenceDelegate {
	func header(scriptName: String) -> String?
}
