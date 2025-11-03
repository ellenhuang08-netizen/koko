//
//  MoneyViewController.swift
//  koko
//
//  Created by 綸綸 on 2025/11/3.
//

import UIKit
import Lottie

class MoneyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let aniView = LottieAnimationView(name: "ani_404")
        view.addSubview(aniView)
        aniView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aniView.topAnchor.constraint(equalTo: view.topAnchor),
            aniView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            aniView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            aniView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        aniView.loopMode = .loop
        aniView.play()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
