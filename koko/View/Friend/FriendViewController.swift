//
//  FriendViewController.swift
//  koko
//
//  Created by 綸綸 on 2025/10/17.
//

import UIKit

class FriendViewController: UIViewController {

    @IBOutlet var inviteBannerHeight: NSLayoutConstraint!
    @IBOutlet var inviteBannerView: InviteBannerView!
    @IBOutlet var emptyFriendView: EmptyFriendView!
    @IBOutlet var userInfoView: UserInfoView!
    
    // 由 Coordinator 設定：在嵌入 FriendsContainerVC 當下把 vm 塞進去
    var onMakeContainerVM: ((FriendsContainerViewController) -> Void)?
    
    private var containerVC: FriendsContainerViewController?
    private let userVM = UserInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await userVM.load();
            if let userInfo = userVM.user {
                userInfoView.configure(with: userInfo)
            }
            
            // 顯示/隱藏空狀態由 Coordinator 先抓好資料決定
            if containerVC == nil {
                embedFriendsContainer()
            }
        }
    }
    
    func embedFriendsContainer() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let child = sb.instantiateViewController(
            withIdentifier: "FriendsContainerVC"
        ) as? FriendsContainerViewController else {
            print("找不到 FriendsContainerVC，請確認 Storyboard ID 是否正確")
            return
        }
        
        // 讓 Coordinator 有機會把 FriendContainerViewModel 注入 child
        onMakeContainerVM?(child)
        
        let invites = child.vm.friendsListVM.invites
        inviteBannerView.isHidden = invites.isEmpty
        inviteBannerHeight.constant = invites.isEmpty ? 0 : inviteBannerView.collapsedHeight
        if !invites.isEmpty {
            inviteBannerView.configure(invites: invites, expanded: false)
        }
        
        // 顯示邀請卡高度變化：接 InviteBanner 回呼
        inviteBannerView.onHeightChange = { [weak self] h in
            self?.inviteBannerHeight.constant = h
            self?.view.layoutIfNeeded()
        }
        
        addChild(child)
        view.addSubview(child.view)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: inviteBannerView.bottomAnchor, constant: 8),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        child.didMove(toParent: self)
        containerVC = child
        
        updateEmptyState(using: child)
    }
    
    private func updateEmptyState(using child: FriendsContainerViewController) {
        let hasFriends = !(child.vm.friendsListVM.friends.isEmpty)
        let hasInvites = !(child.vm.friendsListVM.invites.isEmpty)
        let isEmpty = !(hasFriends || hasInvites)

        // 空狀態顯示
        emptyFriendView.isHidden = !isEmpty

        // PageVC 隱藏
        child.view.isHidden = isEmpty
        child.view.isUserInteractionEnabled = !isEmpty

        // 邀請 Banner 也依資料決定
        inviteBannerView.isHidden = !hasInvites
        inviteBannerHeight.constant = hasInvites ? inviteBannerView.collapsedHeight : 0
        view.layoutIfNeeded()

        // 讓 emptyFriendView 在最上層
        view.bringSubviewToFront(emptyFriendView)
    }
}
