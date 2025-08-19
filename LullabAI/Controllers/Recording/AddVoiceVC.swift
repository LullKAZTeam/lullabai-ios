//
//  AddVoiceVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 22/01/25.
//

import UIKit

class AddVoiceVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onClickContinue(_ sender: Any) {
        let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(withIdentifier: "RecordVoiceVC") as! RecordVoiceVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onClickSkipHome(_ sender: Any) {
        _appDelegate.makeRootView(rootVC: .Home)
    }
}
