//
//  AppCoordinator.swift
//  koko
//
//  Created by 綸綸 on 2025/10/20.
//

import UIKit

final class AppCoordinator {
    let window: UIWindow
    init(window: UIWindow) { self.window = window }
    
    func start() {
        if ScenarioStore.current == nil {
            showScenarioPicker()
        } else {
            // 已有情境也可以先預取再進主畫面
            preloadAndShowMain(ScenarioStore.current!)
        }
        window.makeKeyAndVisible()
    }
    
    // 供設定頁呼叫：重置並回到情境挑選
    func resetAndShowPicker() {
        ScenarioStore.reset()
        showScenarioPicker()
    }

    private func showScenarioPicker() {
        let picker = ScenarioPickerViewController()
        picker.onPick = { [weak self] scenario in
            ScenarioStore.current = scenario
            self?.preloadAndShowMain(scenario)
        }
        window.rootViewController = UINavigationController(rootViewController: picker)
    }

    // 先抓資料，再把主畫面換上，並注入VM
    private func preloadAndShowMain(_ scenario: DataScenario) {
        // loading 畫面（避免空白）
        let loadingVC = LoadingViewController()
        window.rootViewController = loadingVC

        Task { @MainActor in
            let friendsVM = FriendListViewModel()
            await friendsVM.loadInitial()

            let containerVM = FriendContainerViewModel(friendsListVM: friendsVM)
            
            // 換主畫面並注入 VM
            let main = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "TabBarRoot") as! UITabBarController
            
            if let friendVC = findFriendVC(in: main) {
                
                // 交付 VM 的唯一窗口：嵌入 Container 當下注入
                friendVC.onMakeContainerVM = { container in
                    container.vm = containerVM
                }
                
            } else {
                print("沒找到 FriendViewController，請檢查 Tab 結構或類別")
            }

            self.window.rootViewController = main
        }
    }
    
    private func findFriendVC(in root: UIViewController) -> FriendViewController? {
        // 自己就是
        if let vc = root as? FriendViewController { return vc }

        // TabBar：向下找每個 tab
        if let tab = root as? UITabBarController {
            for child in tab.viewControllers ?? [] {
                if let vc = findFriendVC(in: child) { return vc }
            }
        }

        // Nav：向下找每層控制器
        if let nav = root as? UINavigationController {
            for child in nav.viewControllers {
                if let vc = findFriendVC(in: child) { return vc }
            }
        }

        // 一般容器，如果你有自訂容器也能涵蓋
        for child in root.children {
            if let vc = findFriendVC(in: child) { return vc }
        }

        return nil
    }
}


