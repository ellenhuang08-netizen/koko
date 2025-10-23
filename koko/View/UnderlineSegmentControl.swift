//
//  UnderlineSegmentControl.swift
//  koko
//
//  Created by 綸綸 on 2025/10/18.
//

import UIKit

final class UnderlineSegmentControl: UIView {

    var onChange: ((Int) -> Void)?
    var selectedIndex: Int { didSet { updateSelection(animated: true) } }

    
    var normalColor: UIColor = UIColor(named: Constants.color.lightGrey)!
    var selectedColor: UIColor = UIColor(named: Constants.color.lightGrey)!
    var indicatorColor: UIColor = .hotPink
    var font: UIFont = .systemFont(ofSize: 20, weight: .semibold)

    
    private let stack = UIStackView()
    private let indicator = UIView()
    private var buttons: [UIButton] = []

    // indicator動畫用
    private var indicatorLeading: NSLayoutConstraint!
    private var indicatorWidth: NSLayoutConstraint!

    // 一次性啟用標記
    private var didActivateConstraints = false
    private var pendingConstraints: [NSLayoutConstraint] = []

    // 預設高度
    override var intrinsicContentSize: CGSize {
        // 上 8 + 文字 24 + 間距 + indicator 4 + 下 8
        CGSize(width: UIView.noIntrinsicMetric, height: 48)
    }

    init(items: [String], defaultIndex: Int = 0) {
        self.selectedIndex = defaultIndex
        super.init(frame: .zero)
        setup(items: items)
        updateSelection(animated: false)
    }

    required init?(coder: NSCoder) {
        self.selectedIndex = 0
        super.init(coder: coder)
        setup(items: [])
    }

    private func setup(items: [String]) {
        // StackView
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 30
        stack.setContentHuggingPriority(.required, for: .horizontal)
        stack.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Buttons
        for (idx, title) in items.enumerated() {
            let bt = UIButton(type: .system)
            bt.setTitle(title, for: .normal)
            bt.titleLabel?.font = font
            bt.setTitleColor(normalColor, for: .normal)
            bt.tag = idx
            bt.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            buttons.append(bt)
            stack.addArrangedSubview(bt)
        }

        // Indicator line
        addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = indicatorColor
        indicator.layer.cornerRadius = 2

        // 預設約束
        indicatorLeading = indicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        indicatorWidth = indicator.widthAnchor.constraint(equalToConstant: 30)

        pendingConstraints = [
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),

            indicator.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 4),
            indicator.heightAnchor.constraint(equalToConstant: 4),
            indicatorLeading,
            indicatorWidth
        ]
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 第一次 layout 才啟用內部約束（避免重複 activate）
        if !didActivateConstraints {
            NSLayoutConstraint.activate(pendingConstraints)
            didActivateConstraints = true
        }

        // 每次 layout 都更新 indicator 的位置
        updateSelection(animated: false)
    }

    // 點擊事件
    @objc private func tap(_ sender: UIButton) {
        guard selectedIndex != sender.tag else { return }
        selectedIndex = sender.tag
        onChange?(selectedIndex)
    }

    // 更新indicator
    private func updateSelection(animated: Bool) {
        guard buttons.indices.contains(selectedIndex),
              let target = buttons[safe: selectedIndex] else { return }

        // 更新文字顏色
        for (i, bt) in buttons.enumerated() {
            bt.setTitleColor(i == selectedIndex ? selectedColor : normalColor, for: .normal)
        }

        // 確保 layout 完成
        layoutIfNeeded()

        // 以 target 寬度決定 indicator 尺寸與位置
        let titleWidth = target.titleLabel?.intrinsicContentSize.width ?? 0
        let leading = stack.frame.minX + target.frame.minX + (target.frame.width - titleWidth)/2

        indicatorLeading.constant = leading
        indicatorWidth.constant = titleWidth

        // 動畫更新
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
                self.layoutIfNeeded()
            }
        }
    }

    func setItems(_ items: [String]) {
        // 清空舊按鈕
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for (idx, title) in items.enumerated() {
            let bt = UIButton(type: .system)
            bt.setTitle(title, for: .normal)
            bt.titleLabel?.font = font
            bt.setTitleColor(normalColor, for: .normal)
            bt.tag = idx
            bt.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            buttons.append(bt)
            stack.addArrangedSubview(bt)
        }
        // 重算一次指示條
        selectedIndex = min(selectedIndex, max(0, items.count - 1))
        setNeedsLayout()
        layoutIfNeeded()
        // 同步一次
        updateSelection(animated: false)
    }
    
    // MARK: - Badge
    func setBadge(_ text: String?, at index: Int) {
        guard let bt = buttons[safe: index] else { return }

        let badgeTag = 999
        bt.viewWithTag(badgeTag)?.removeFromSuperview()
        guard let text = text, !text.isEmpty, text != "0" else { return }

        let badge = PaddingLabel()
        badge.tag = badgeTag
        badge.text = text
        badge.font = .systemFont(ofSize: 12, weight: .bold)
        badge.textColor = .white
        badge.backgroundColor = .systemPink.withAlphaComponent(0.9)
        badge.layer.cornerRadius = 10
        badge.clipsToBounds = true
        badge.textAlignment = .center
        badge.translatesAutoresizingMaskIntoConstraints = false

        bt.addSubview(badge)

        NSLayoutConstraint.activate([
            badge.leadingAnchor.constraint(equalTo: bt.titleLabel!.trailingAnchor, constant: 3),
            badge.centerYAnchor.constraint(equalTo: bt.titleLabel!.centerYAnchor, constant: -10)
        ])

        DispatchQueue.main.async {
            badge.layer.cornerRadius = badge.frame.height / 2
        }
    }
}

// MARK: - Safe Array Access
private extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

