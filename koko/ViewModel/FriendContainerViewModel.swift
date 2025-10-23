//
//  FriendContainerViewModel.swift
//  koko
//
//  Created by 綸綸 on 2025/10/18.
//

import Foundation
@MainActor
class FriendContainerViewModel {

    private(set) var titles = ["好友", "聊天"]
    private(set) var selectedIndex: Int = 0 {
        didSet { onSelectedIndexChanged?(selectedIndex) }
    }
    
    let friendsListVM: FriendListViewModel
    
    private var invitesCount: Int { friendsListVM.invites.count }
    
    
    // Badges
    var friendsBadgeText: String? { invitesCount > 0 ? "\(min(invitesCount, 99))" : nil }
    var chatBadgeText = "99+"
    
    
    // Outputs (綁定給 VC)
    var onSelectedIndexChanged: ((Int) -> Void)?
    var onBadgesChanged: ((_ friends: String?, _ chat: String?) -> Void)?
    
    init(friendsListVM: FriendListViewModel) {
        self.friendsListVM = friendsListVM
    }
    
    func select(index: Int) { selectedIndex = index }
    
    func refreshBadges() {
        onBadgesChanged?(friendsBadgeText, chatBadgeText)
    }
}
