//
//  PaddingLabel.swift
//  koko
//
//  Created by 綸綸 on 2025/10/19.
//
import UIKit

final class PaddingLabel: UILabel {
    var inset = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + inset.left + inset.right,
                      height: size.height + inset.top + inset.bottom)
    }
}
