//
//  EmptyFriendView.swift
//  koko
//
//  Created by 綸綸 on 2025/10/20.
//

import UIKit

class EmptyFriendView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var addFriendBtn: UIButton!
    
    @IBOutlet var settingLabel: UILabel!
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
        bundle.loadNibNamed("EmptyFriendView", owner: self, options: nil)
        
        guard let contentView = contentView else { return }

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        settingBtn()
        settingUILabel()
    }

    // 按鈕樣式
    private func settingBtn() {
        self.addFriendBtn.layer.cornerRadius = 20
        self.addFriendBtn.clipsToBounds = true
        
        // 做漸層
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.addFriendBtn.frame.size)
        gradient.colors = [UIColor(named: Constants.color.frogGreen)!.cgColor,
                           UIColor(named: Constants.color.b)!.cgColor]
        gradient.startPoint = CGPointMake(0, 0)
        gradient.endPoint = CGPointMake(1, 0)
        gradient.locations = [0.5,1.0]

        self.addFriendBtn.layer.addSublayer(gradient)
        self.addFriendBtn.bringSubviewToFront(self.addFriendBtn.titleLabel!)
        self.addFriendBtn.bringSubviewToFront(self.addFriendBtn.imageView!)
    }
    
    // label樣式
    private func settingUILabel() {
        let fullText = "幫助好友更快找到你？設定 KOKO ID"
        let underlineText = "設定 KOKO ID"

        // 建立 NSMutableAttributedString
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .foregroundColor: UIColor(named: Constants.color.warmGrey)!,
                .font: UIFont.systemFont(ofSize: 15)
            ]
        )

        // 找出粉紅文字的範圍
        if let range = fullText.range(of: underlineText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([
                .foregroundColor: UIColor(named: Constants.color.hotPink)!,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor(named: Constants.color.hotPink)!
            ], range: nsRange)
        }

        settingLabel.attributedText = attributedString
    }
}
