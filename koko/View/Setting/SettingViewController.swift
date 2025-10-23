//
//  SettingViewController.swift
//  koko
//
//  Created by 綸綸 on 2025/10/20.
//

import UIKit

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 重新選擇模式
    @IBAction func clickBtn(_ sender: Any) {
        ScenarioStore.reset()
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate {
            sceneDelegate.appCoordinator?.resetAndShowPicker()
        }
    }
}
