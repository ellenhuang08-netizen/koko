//
//  FriendsContainerViewController.swift
//  koko
//
//  Created by 綸綸 on 2025/10/18.
//

import UIKit

class FriendsContainerViewController: UIViewController {
    
    private let header = UnderlineSegmentControl(items: [], defaultIndex: 0)
    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    var vm: FriendContainerViewModel!
    
    private lazy var pages: [UIViewController] = {
        let friendsVC = FriendListViewController(viewModel: vm.friendsListVM)
        let chatVC = UIViewController()
            return [friendsVC, chatVC]
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Header
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // PageVC
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: header.bottomAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self
        
        // 初始化segment
        header.setItems(vm.titles)
        header.selectedIndex = vm.selectedIndex
        
        vm.onSelectedIndexChanged = { [weak self] idx in
            guard let self else { return }
            self.header.selectedIndex = idx
            self.pageVC.setViewControllers([self.pages[idx]], direction: .forward, animated: false)
        }
        
        vm.onBadgesChanged = { [weak self] fBadge, cBadge in
            self?.header.setBadge(fBadge, at: 0)
            self?.header.setBadge(cBadge, at: 1)
        }
        
        header.onChange = { [weak vm] idx in vm?.select(index: idx) }
        
        // 初始頁 + badge
        pageVC.setViewControllers([pages[vm.selectedIndex]], direction: .forward, animated: false)
        vm.refreshBadges()
    }
}

// MARK: - PageVC delegate/datasource（Page → Segment）
extension FriendsContainerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pvc: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: vc), idx > 0 else { return nil }
        return pages[idx - 1]
    }
    
    func pageViewController(_ pvc: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: vc), idx < pages.count - 1 else { return nil }
        return pages[idx + 1]
    }
    
    func pageViewController(_ pvc: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let current = pvc.viewControllers?.first, let idx = pages.firstIndex(of: current) else { return }
        vm.select(index: idx)
    }
}
