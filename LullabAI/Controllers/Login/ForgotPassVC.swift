//
//  ForgotPassVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 13/01/25.
//

import UIKit

class ForgotPassVC: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}
extension ForgotPassVC {
    
    @IBAction func onClickSignin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickContinue(_ sender: Any) {
        
        self.view.endEditing(true)
        if txtEmail.text!.isEmail == false {
            self.presentAlert(withTitle: "Oops!", message: "Please enter valid email")
        }
        else {
            forgotPass()
        }
    }
}

extension ForgotPassVC {
    
    func forgotPass() {
        
        let param = ["email":txtEmail.text!]
        
        _ = ApiHandler.shared.request(for: .forgotPassword, param: param, vc: self) { status, json, error in
            
            switch status {
            case .success:
                let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(withIdentifier: "CreateNewPassVC") as! CreateNewPassVC
                nextVC.strEmail = self.txtEmail.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
            case .processing:
                break
            case .failed:
                
                if let msg = (json?["data"] as? [String:Any])?["error"] as? String {
                    self.presentAlert(withTitle: NSLocalizedString("Oops!", comment: ""), message: msg)
                }
            }
        }
    }
}
