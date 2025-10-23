//
//  UserInfoView.swift
//  koko
//
//  Created by 綸綸 on 2025/10/17.
//

import UIKit

class UserInfoView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var kokoIdLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    
    @IBOutlet var pinkDot: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // 載入xib
    private func commonInit() {
        // 避免重複載入
        guard contentView == nil else { return }
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed("UserInfoView", owner: self, options: nil)
        
        guard let contentView = contentView else { return }

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        pinkDot.layer.cornerRadius = 5
    }
    
    // 更新 UI
    func configure(with user: User) {
        nameLabel.text = user.name
        if !user.kokoid.isEmpty {
            kokoIdLabel.text = "KOKO ID：\(user.kokoid)"
            pinkDot.isHidden = true
        } else {
            kokoIdLabel.text = "設定 KOKO ID"
            pinkDot.isHidden = false
        }
    }
}
