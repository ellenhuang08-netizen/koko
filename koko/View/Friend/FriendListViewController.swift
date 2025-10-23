//
//  FriendListViewController.swift
//  koko
//
//  Created by 綸綸 on 2025/10/19.
//

import UIKit

class FriendListViewController: UIViewController {

    @IBOutlet var searchField: UITextField!
    @IBOutlet var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var friends:[Friend] = [] // 原資料
    var filterResult: [Friend] = [] // 顯示用(過濾後)
    
    // debounce
    private var debounceWorkItem: DispatchWorkItem?
    private let debounceInterval: TimeInterval = 0.25
    
    // 由上層注入
    var injectedVM: FriendListViewModel? {
        didSet {
            // 若 view 已載入，立刻套資料
            if isViewLoaded {
                applyVM()
            }
        }
    }
    
    init(viewModel: FriendListViewModel? = nil) {
        self.injectedVM = viewModel
        super.init(nibName: String(describing: FriendListViewController.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView
        tableView.delegate = self
        tableView.dataSource = self
        registerTableViewCell()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.backgroundColor = .white
        
        // 下拉更新
        refreshControl.attributedTitle = NSAttributedString(string: "拉一下更新好友")
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSearchFieldTap))
        searchField.addGestureRecognizer(tapGesture)
        setupSearchField()
        
        applyVM()
    }
    
    // 處理 Tap Gesture
    @objc func handleSearchFieldTap() {
        self.searchField.becomeFirstResponder()
    }
    
    
    private func setupSearchField() {
        searchField.returnKeyType = .done
        searchField.clearButtonMode = .whileEditing
        searchField.borderStyle = .roundedRect
        searchField.delegate = self
        searchField.isUserInteractionEnabled = true
        searchField.backgroundColor = .steel12
        let placeholderText = "想轉一筆給誰呢？"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: Constants.color.steel)!
        ]
        
        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        self.searchField.attributedPlaceholder = attributedPlaceholder
        // 左邊放大鏡圖示
        let iconView = UIImageView()
        iconView.image = UIImage(named: "ic_SearchBarSearchGray")
        iconView.tintColor = .gray
        iconView.contentMode = .scaleAspectFit

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 20))
        container.addSubview(iconView)
        
        iconView.frame = CGRect(x: 8, y: 2, width: 16, height: 16) // 16x16 圖，左邊距 8

        self.searchField.leftView = container
        self.searchField.leftViewMode = .always
    }
    
    // 監聽文字變化
    @IBAction func onSearchTextChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        debounceWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.applyFilterAndReload(keyword: text)
        }
        debounceWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: work)
    }
    
    private func registerTableViewCell() {
        let nib = UINib(nibName: "FriendListTableViewCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "FriendListTableViewCell")
    }
    
    private func applyVM() {
        guard let vm = injectedVM else { return }
        friends = vm.friends
        applyFilterAndReload(keyword: self.searchField.text ?? "")
    }
    
    // 過濾
    private func applyFilterAndReload(keyword: String) {
        let kw = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if kw.isEmpty {
            filterResult = friends
        } else {
            filterResult = friends.filter { $0.name.contains(kw) }
        }
        tableView.reloadData()
    }
    
    // 下拉更新
    @objc private func onPullToRefresh() {
        Task {
            // 若有注入的 VM：依目前情境重載；否則用預設載入
            if let vm = injectedVM {
                await vm.loadInitial()
                friends = vm.friends
            } else {
                let vm = FriendListViewModel()
                await vm.loadInitial()
                injectedVM = vm
                friends = vm.friends
            }
            
            applyFilterAndReload(keyword: self.searchField.text ?? "")
            refreshControl.endRefreshing()
        }
    }
}

extension FriendListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListTableViewCell") as! FriendListTableViewCell
        let friend = filterResult[indexPath.row]
        
        cell.configure(with: friend)
        return cell
    }
    
    // 點cell收回鍵盤
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension FriendListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
