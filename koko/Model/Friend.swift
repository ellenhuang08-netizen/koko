//
//  Friend.swift
//  koko
//
//  Created by 綸綸 on 2025/10/17.
//

import Foundation

struct Friend: Codable {
    let name: String // 姓名
    let status: Int // 狀態(0:邀請送出, 1:已完成, 2:邀請中)
    let isTop: String // 是否出現星星
    let fid: String // 好友id
    let updateDate: String // 資料更新時間
    
    var isTopBool:Bool { isTop == "1" } // 使用時改用 isTopBool
}

extension Friend {
    // format，回傳資料的日期格式不同
    var parsedUpdateDate: Date? {
        let fmts = ["yyyyMMdd", "yyyy/MM/dd", "yyyy-MM-dd"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        for fmt in fmts {
            formatter.dateFormat = fmt
            if let d = formatter.date(from: updateDate) {
                return d
            }
        }
        return nil
    }
}
