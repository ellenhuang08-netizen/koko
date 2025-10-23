//
//  UserInfoViewModel.swift
//  koko
//
//  Created by 綸綸 on 2025/10/18.
//

import Foundation
@MainActor
class UserInfoViewModel {
    private(set) var user: User?
    
    func load() async {
        let url = URL(string: Constants.serverUrl.userInfo)!
        do {
            let users: [User] = try await APIService.shared.fetchWrapped(url)
            self.user = users.first
        } catch {
            print("User fetch failed:", error)
            self.user = nil
        }
    }
}
