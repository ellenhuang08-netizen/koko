//
//  CustomTextField.swift
//  koko
//
//  Created by 綸綸 on 2025/10/22.
//

import UIKit

class CustomTextField: UITextField {
    // 設置 leftView 與文字輸入區域之間的距離
    let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10) // 右邊間距 10

    // 決定文字輸入區域 (Text Rect) 的範圍
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        // 排除 leftView 的寬度（如果 leftViewMode 是 .always）
        let leftViewWidth = leftView?.frame.size.width ?? 0
        
        return bounds.inset(by: padding).offsetBy(dx: leftViewWidth, dy: 0)
    }

    // 決定編輯文字區域 (Editing Rect) 的範圍 (包含游標)
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        // 排除 leftView 的寬度（如果 leftViewMode 是 .always）
        let leftViewWidth = leftView?.frame.size.width ?? 0
        
        // 給游標和文字留出空間
        // 將整個區域向右偏移 leftView 的寬度，並使用內邊距。
        return bounds.inset(by: padding).offsetBy(dx: leftViewWidth, dy: 0)
    }

    // 決定 leftView 的位置
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        
        let containerWidth: CGFloat = 28.0
        let containerHeight: CGFloat = 20.0
        
        return CGRect(x: 0, y: (bounds.height - containerHeight) / 2, width: containerWidth, height: containerHeight)
    }
}
