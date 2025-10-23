//
//  FriendListViewModel.swift
//  koko
//
//  Created by 綸綸 on 2025/10/17.
//
import Foundation

@MainActor
class FriendListViewModel {
    var friends: [Friend] = []
    var invites: [Friend] = [] // status == 0
    
    // 起始載入，根據情境切換不同API
    func loadInitial() async {
        switch ScenarioStore.current {
        case.empty:
            await loadLists(from: [URL(string: Constants.serverUrl.noInfo)!])
        case.friendsOnly:
            await loadLists(from: [URL(string: Constants.serverUrl.friendList1)!,
                                   URL(string: Constants.serverUrl.friendList2)!])
        case.friendsWithInvites:
            await loadLists(from: [URL(string: Constants.serverUrl.friendListWithInvited)!])
        case.none:
            await loadLists(from: [])
        }
    }
    

    func refresh() async { await loadInitial() }

    
    private func loadLists(from urls: [URL]) async {
        do {
            // 併發抓取
            let lists: [[Friend]] = try await withThrowingTaskGroup(of: [Friend].self) { group in
                for url in urls {
                    group.addTask {
                        try await APIService.shared.fetchWrapped(url)
                    }
                }
                var collected: [[Friend]] = []
                for try await result in group {
                    collected.append(result)
                }
                return collected
            }

            // 合併成一個陣列
            let all = lists.flatMap { $0 }
            
            // 以 fid 去重並取 updateDate 最新者
            let latestByFID: [Friend] = Dictionary(grouping: all, by: { $0.fid })
                .compactMap { _, arr in arr.max(by: { ($0.parsedUpdateDate ?? .distantPast) < ($1.parsedUpdateDate ?? .distantPast) }) }
            
            // 依日期排序
            let sorted = latestByFID.sorted { a,b in                a.parsedUpdateDate ?? .distantPast > b.parsedUpdateDate ?? .distantPast
            }
            
            // 置頂：isTopBool == true 的在前，其餘順序不變
            let tops    = sorted.filter { $0.isTopBool }
            let normals = sorted.filter { !$0.isTopBool }
            let result  = tops + normals
            

            print("urls:\(urls)")
            self.friends = result.filter{ $0.status != 0 }
            self.invites = result.filter { $0.status == 0}
            print("friends:\(self.friends)")
            print("invite:\(self.invites)")
        } catch {
            print("Load error:", error)
            self.friends = []
        }
    }
}
