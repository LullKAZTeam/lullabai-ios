//
//  CreateNewPassVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 13/01/25.
//

import UIKit

class CreateNewPassVC: UIViewController {

    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfPassword: UITextField!
    
    var strEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickSignin(_ sender: Any) {
        
        var isFindVC = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: SigninVC.self) {
                isFindVC = true
                _ =  self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        
        if !isFindVC {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func onClickUpdatePass(_ sender: Any) {
        
        self.view.endEditing(true)
        if txtNewPassword.text! == "" || txtConfPassword.text! == "" {
            self.presentAlert(withTitle: "Oops!", message: "Please enter valid details")
        }
        else if txtNewPassword.text! != txtConfPassword.text! {
            self.presentAlert(withTitle: "Oops!", message: "Password does not match")
        }
        else {
            let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
            nextVC.strEmail = strEmail
            nextVC.strNewPassword = txtNewPassword.text!
            nextVC.isFrom = "NewPass"
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}
