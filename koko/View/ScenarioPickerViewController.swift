//
//  ScenarioPickerViewController.swift
//  koko
//
//  Created by 綸綸 on 2025/10/20.
//

import UIKit

final class ScenarioPickerViewController: UIViewController {

    var onPick: ((DataScenario) -> Void)?   // 決定後回呼（啟動協調器用）

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let confirmButton = UIButton(type: .system)
    private let vm = ScenarioPickerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "選擇資料情境"
        view.backgroundColor = .white

        // Table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // Button
        confirmButton.setTitle("開始使用", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        confirmButton.isEnabled = vm.selected != nil
        confirmButton.backgroundColor = confirmButton.isEnabled ? .systemPink : .systemGray3
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 12
        confirmButton.addTarget(self, action: #selector(onConfirm), for: .touchUpInside)

        let buttonContainer = UIView()
        buttonContainer.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(buttonContainer)
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // table
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // button container
            buttonContainer.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            buttonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            confirmButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            confirmButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 12),
            confirmButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: -12),
            confirmButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])
    }

    @objc private func onConfirm() {
        guard let s = vm.selected else { return }
        vm.confirmSelection()
        onPick?(s)
    }
}

extension ScenarioPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.scenarios.count
    }
    
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let s = vm.scenarios[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = s.displayName
        cfg.secondaryText = {
            switch s {
            case .empty: return "friend4.json"
            case .friendsOnly: return "friend1.json + friend2.json"
            case .friendsWithInvites: return "friend3.json"
            }
        }()
        cfg.textProperties.color = .black
        cell.backgroundColor = .white
        cell.contentConfiguration = cfg
        cell.accessoryType = (s == vm.selected) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let s = vm.scenarios[indexPath.row]
        vm.select(s)
        confirmButton.isEnabled = true
        confirmButton.backgroundColor = .systemPink
        tv.reloadData()
    }
}
