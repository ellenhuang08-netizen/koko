//
//  FriendListTableViewCell.swift
//  koko
//
//  Created by 綸綸 on 2025/10/19.
//

import UIKit

class FriendListTableViewCell: UITableViewCell {
    
    @IBOutlet var invitedBtn: UIButton! // 邀請中button
    @IBOutlet var transferBtn: UIButton! // 轉帳button
    @IBOutlet var moreFuncBtn: UIButton! // 更多Button
    @IBOutlet var starImg: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        adjustUI()
    }
    private func adjustUI() {
        transferBtn.layer.cornerRadius = 2
        transferBtn.layer.borderWidth = 1.2
        transferBtn.layer.borderColor = UIColor(named: Constants.color.hotPink)?.cgColor
        
        invitedBtn.layer.cornerRadius = 2
        invitedBtn.layer.borderWidth = 1.2
        invitedBtn.layer.borderColor = UIColor(named: Constants.color.pinkishGrey)?.cgColor
    }
    
    func configure(with friend: Friend) {
        self.backgroundColor = .white
        nameLabel.text = friend.name
        // 根據狀態決定UI是否顯示
        /*
         status 0:對方已邀請
         status 1:已完成
         status 2:邀請中
         */
        if friend.status == 1 {
            invitedBtn.isHidden = true
            moreFuncBtn.isHidden = false
        } else if friend.status == 2 {
            invitedBtn.isHidden = false
            moreFuncBtn.isHidden = true
        } else {
            invitedBtn.isHidden = true
            moreFuncBtn.isHidden = true
        }
        
        if friend.isTopBool == false {
            starImg.isHidden = true
        } else {
            starImg.isHidden = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
