//
//  APIService.swift
//  koko
//
//  Created by 綸綸 on 2025/10/17.
//

import Foundation

class APIService {
    static let shared = APIService()
    private init() {}
    // 解析成 APIResponse<T>，回傳內層的 `response`
    func fetchWrapped<T: Decodable>(_ url: URL) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: url)
        let wrapper = try JSONDecoder().decode(APIResponse<T>.self, from: data)
        return wrapper.response
    }
}
