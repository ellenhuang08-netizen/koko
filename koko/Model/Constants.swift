//
//  Constants.swift
//  koko
//
//  Created by 綸綸 on 2025/10/17.
//

import Foundation

struct Constants {
    struct serverUrl {
        static let userInfo = "https://dimanyen.github.io/man.json"
        static let friendList1 = "https://dimanyen.github.io/friend1.json"
        static let friendList2 = "https://dimanyen.github.io/friend2.json"
        static let friendListWithInvited = "https://dimanyen.github.io/friend3.json"
        static let noInfo = "https://dimanyen.github.io/friend4.json"
    }
    
    struct color {
        static let hotPink = "HotPink"
        static let warmGrey = "WarmGrey"
        static let pinkishGrey = "PinkishGrey"
        static let lightGrey = "LightGrey"
        static let veryLightPink = "VeryLightPink"
        static let frogGreen = "FrogGreen"
        static let b = "B"
        static let steel_12 = "Steel_12%"
        static let steel = "Steel"
    }
}

// 模擬啟動時要載入的情境
enum DataScenario: String, CaseIterable {
    case empty              // 無好友畫面 → friend4
    case friendsOnly        // 只有好友列表 → friend1 + friend2
    case friendsWithInvites // 好友列表含邀請 → friend3

    var displayName: String {
        switch self {
        case .empty: return "無好友"
        case .friendsOnly: return "只有好友"
        case .friendsWithInvites: return "好友含邀請"
        }
    }
}

// 儲存與讀取目前選擇的情境
enum ScenarioStore {
    private static let key = "data_scenario"

    static var current: DataScenario? {
        get {
            guard let raw = UserDefaults.standard.string(forKey: key) else { return nil }
            return DataScenario(rawValue: raw)
        }
        set {
            UserDefaults.standard.setValue(newValue?.rawValue, forKey: key)
        }
    }

    // 快速重設情境
    static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
