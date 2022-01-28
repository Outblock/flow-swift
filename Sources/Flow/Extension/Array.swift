//
//  Array.swift
//
//  Copyright 2021 Zed Labs Pty Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

extension Array where Iterator.Element: Hashable {
    func hash(into hasher: inout Hasher) {
        for obj in self {
            hasher.combine(obj)
        }
    }
}

public extension Array where Element == Flow.Cadence.FValue {
    func toArguments() -> [Flow.Argument] {
        return compactMap(Flow.Argument.init)
    }
}
