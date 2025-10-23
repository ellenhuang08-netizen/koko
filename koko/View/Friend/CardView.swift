//
//  CardView.swift
//  koko
//
//  Created by 綸綸 on 2025/10/21.
//

import UIKit

class CardView: UIView {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var contentView: UIView!
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
        bundle.loadNibNamed("CardView", owner: self, options: nil)
        
        guard let contentView = contentView else { return }

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        backgroundColor = .white
        contentView.backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 16
    }

    func configure(with friend: Friend) {
        nameLabel.text = friend.name
    }
}
