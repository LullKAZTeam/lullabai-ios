//
//  IntroVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 13/01/25.
//

import UIKit

class IntroVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickStart(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogin") {
            _appDelegate.makeRootView(rootVC: rootView.Home)
        }
        else {
            _appDelegate.makeRootView(rootVC: rootView.Login)
        }
    }

}
