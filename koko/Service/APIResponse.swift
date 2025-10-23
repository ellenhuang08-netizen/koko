//
//  APIResponse.swift
//  koko
//
//  Created by 綸綸 on 2025/10/17.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let response: T
}
