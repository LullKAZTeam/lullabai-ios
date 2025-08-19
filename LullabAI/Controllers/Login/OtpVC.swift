//
//  OtpVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 13/01/25.
//

import UIKit

class OtpVC: UIViewController {

    @IBOutlet var lblOTP: [UILabel]!
    @IBOutlet weak var txtOtp: UITextField!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    var strEmail = ""
    var isFrom = ""
    var strNewPassword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblSubTitle.text = "Enter 4-digit code sent to your email\n\(strEmail)"
        txtOtp.delegate = self
        txtOtp.addTarget(self, action: #selector(textFeildDidChange), for: .editingChanged)
    }
    
    @IBAction func onClickOTP(_ sender: UIButton) {
        
        UIImpactFeedbackGenerator().impactOccurred()
        txtOtp.becomeFirstResponder()
    }
    
    @IBAction func onClickSigin(_ sender: Any) {
        _appDelegate.makeRootView(rootVC: .Login)
    }
    
    @IBAction func onClickVerify(_ sender: Any) {
        self.view.endEditing(true)
        verifyOTP()
    }
}

//MARK: Extension UITextFieldDelegate
extension OtpVC : UITextFieldDelegate {
    
    @objc func textFeildDidChange(_ textfeild : UITextField) {
        
        resetValue()
        
        let value = textfeild.text?.map { String($0) }
        
        for i in 0..<(textfeild.text?.count ?? 0) {
            lblOTP[i].text = value?[i]
        }
        
        if textfeild.text?.count == 4 {
            self.view.endEditing(true)
            verifyOTP()
        }
    }
    
    func resetValue() {
        lblOTP.forEach { label in
            label.text = "-"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.text?.count ?? 0 < 4 || string == ""
    }
}

extension OtpVC {
    
    func verifyOTP() {
        
        if self.isFrom == "NewPass" {
            
            let param = ["email": strEmail,
                         "otp": txtOtp.text!,
            "new_password": strNewPassword]
            
            _ = ApiHandler.shared.request(for: .resetPassword, param: param, vc: self) { status, json, error in
                
                switch status {
                case .success:
                    self.presentAlertWithCompletion(title: "Success", message: "Password updated successfully!", options: ["OK"], optionStyle: [.default]) { action in
                        _appDelegate.makeRootView(rootVC: .Login)
                    }
                case .processing:
                    break
                case .failed:
                    
                    if let msg = (json?["data"] as? [String:Any])?["error"] as? String {
                        self.presentAlert(withTitle: NSLocalizedString("Oops!", comment: ""), message: msg)
                    }
                }
            }
        }
        else {
            let param = ["email":strEmail,
                         "otp": txtOtp.text!]
            
            _ = ApiHandler.shared.request(for: .verifyOTP, param: param, vc: self) { status, json, error in
                
                switch status {
                case .success:
                    
                    if let data = json?["data"] as? [String:Any], let tokens = data["tokens"] as? [String:Any] {
                        
                        UserDefaults.standard.setValue("\(tokens["access"] ?? "")", forKey: "accesss_token")
                        UserDefaults.standard.setValue("\(tokens["refresh"] ?? "")", forKey: "refresh_token")
                        UserDefaults.standard.setValue(true, forKey: "isLogin")
                        UserDefaults.standard.synchronize()
                        
                        self.getVoice()
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
    
    func getVoice() {
        
        _ = ApiHandler.shared.request(.get, for: .getVoice, param: nil, vc: self) { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any], let voice = data["voices"] as? [[String:Any]] {
                    if voice.count > 0 {
                        _appDelegate.makeRootView(rootVC: .Home)
                    }
                    else {
                        _appDelegate.makeRootView(rootVC: .AddVoice)
                    }
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
