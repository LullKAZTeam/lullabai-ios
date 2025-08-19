//
//  SigninVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 13/01/25.
//

import UIKit
import AuthenticationServices
import GoogleSignIn

class SigninVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension SigninVC {
    
    @IBAction func onClickGoogle(_ sender: Any) {
        self.view.endEditing(true)
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            print(signInResult?.user.idToken?.tokenString)
            self.socialLogin(type: "google", token: signInResult?.user.idToken?.tokenString ?? "")
            // If sign in succeeded, display the app's main content View.
          }
    }
    
    @IBAction func onClickApple(_ sender: Any) {
        self.view.endEditing(true)
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @IBAction func onClickForgotPass(_ sender: Any) {
        self.view.endEditing(true)
        let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(identifier: "ForgotPassVC") as! ForgotPassVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onClickSignin(_ sender: Any) {
        
        self.view.endEditing(true)
        if txtEmail.text! == "" || txtPassword.text! == "" {
            self.presentAlert(withTitle: "Oops!", message: "Please enter valid details")
        }
        else if txtEmail.text!.isEmail == false {
            self.presentAlert(withTitle: "Oops!", message: "Please enter valid email")
        }
        else {
            login()
        }
    }
    
    @IBAction func onClickCreateAccount(_ sender: Any) {
        self.view.endEditing(true)
        let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(identifier: "SigninupVC") as! SigninupVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onClickPrivacyPolicy(_ sender: Any) {
        let nextVC = Constants.StoryBoard.PROFILE.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onClickTerms(_ sender: Any) {
        let nextVC = Constants.StoryBoard.PROFILE.instantiateViewController(withIdentifier: "TermsConditionsVC") as! TermsConditionsVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension SigninVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - ASAuthorizationControllerDelegate Methods
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("User ID: \(userIdentifier)")
            print("Full Name: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
            print("Email: \(email ?? "No Email")")
            
            if let identityToken = appleIDCredential.identityToken {
                let tokenString = String(data: identityToken, encoding: .utf8)
                print("Identity Token: \(tokenString ?? "Unable to decode token")")
                
                socialLogin(type: "apple", token: tokenString ?? "")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization failed: \(error.localizedDescription)")
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension SigninVC {
    
    func login() {
        let param = ["email":txtEmail.text!,
                     "password": txtPassword.text!]
        
        _ = ApiHandler.shared.request(for: .login, param: param, vc: self) { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any], let userData = data["user"] as? [String:Any], let tokens = data["tokens"] as? [String:Any] {
                    
                    var user = userData
                    for (key, value) in user {
                        if value is NSNull {
                            user[key] = ""
                        }
                    }
                    
                    UserDefaults.standard.setValue(user, forKey: "userInfo")
                    UserDefaults.standard.setValue("\(userData["id"] ?? "")", forKey: "userId")
                    UserDefaults.standard.synchronize()
                    
                    if "\(userData["verified"] ?? "0")" == "0" {
                        
                        let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
                        nextVC.strEmail = "\(userData["email"] ?? "")"
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
                    else {
                        UserDefaults.standard.setValue("\(tokens["access"] ?? "")", forKey: "accesss_token")
                        UserDefaults.standard.setValue("\(tokens["refresh"] ?? "")", forKey: "refresh_token")
                        UserDefaults.standard.setValue(true, forKey: "isLogin")
                        UserDefaults.standard.synchronize()
                        self.getVoice()
                    }
                }
            case .processing:
                break
            case .failed:

                if let data = json?["data"] as? [String:Any], let error = data["error"] as? String {
                        self.presentAlert(withTitle: "Oops!", message: error)
                    }
            }
        }
    }
    
    func socialLogin(type:String, token:String) {
        
        let param = ["provider":type,
                     "id_token": token]
        
        _ = ApiHandler.shared.request(for: .socialLogin, param: param, vc: self) { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any], let userData = data["user"] as? [String:Any], let tokens = data["tokens"] as? [String:Any] {
                    
                    var user = userData
                    for (key, value) in user {
                        if value is NSNull {
                            user[key] = ""
                        }
                    }
                    
                    UserDefaults.standard.setValue(user, forKey: "userInfo")
                    UserDefaults.standard.setValue("\(userData["id"] ?? "")", forKey: "userId")
                    UserDefaults.standard.setValue(true, forKey: "isSocial")
                    UserDefaults.standard.synchronize()
                    
                    UserDefaults.standard.setValue("\(tokens["access"] ?? "")", forKey: "accesss_token")
                    UserDefaults.standard.setValue("\(tokens["refresh"] ?? "")", forKey: "refresh_token")
                    UserDefaults.standard.setValue(true, forKey: "isLogin")
                    UserDefaults.standard.synchronize()
                    self.getVoice()
                }
            case .processing:
                break
            case .failed:

                if let data = json?["data"] as? [String:Any], let error = data["error"] as? String {
                        self.presentAlert(withTitle: "Oops!", message: error)
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
