//
//  DeleteAccountVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 14/02/25.
//

import UIKit

class DeleteAccountVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onClickDeleteAccount(_ sender: Any) {
        
        let param = [String:Any]()
        
        _ = ApiHandler.shared.request(for: .deleteAccount, param: param.keys.count > 0 ? param : nil, vc: nil) { status, json, error in
            
            switch status {
            case .success:
                
                self.presentAlertWithCompletion(title: "Alert", message: "Your account has been successfully deleted.", options: ["Ok"], optionStyle: [.default]) { index in
                    
                    UserDefaults.standard.removeObject(forKey: "userInfo")
                    UserDefaults.standard.removeObject(forKey: "userId")
                    UserDefaults.standard.removeObject(forKey: "isLogin")
                    UserDefaults.standard.removeObject(forKey: "isSocial")
                    UserDefaults.standard.removeObject(forKey: "accesss_token")
                    VoiceHandler.shared.arrayVoices.removeAll()
                    _appDelegate.makeRootView(rootVC: .Login)
                }
            case .processing:
                break
            case .failed:
                
                if let msg = json?["message"] as? String {
                    self.presentAlert(withTitle: NSLocalizedString("Oops!", comment: ""), message: msg)
                }
            }
        }
    }
}
