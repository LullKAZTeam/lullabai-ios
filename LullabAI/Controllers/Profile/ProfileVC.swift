//
//  ProfileVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 20/01/25.
//

import UIKit
import GoogleSignIn

class ProfileVC: UIViewController {
    
    @IBOutlet weak var imgViewUser: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    @IBOutlet weak var viewDeleteAccount: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        if let userData = UserDefaults.standard.object(forKey: "userInfo") as? [String:Any] {
            lblUsername.text = userData["name"] as? String
            lblUserEmail.text = userData["email"] as? String
            
            if let profile = userData["profile_image"] as? String, profile != "" {
                imgViewUser.kf.setImage(with: URL(string: profile), placeholder: nil)
            }
            else {
                imgViewUser.image = UIImage(named: "ic_ProfileHeader")
            }
        }
    }
    
    @IBAction func onClickManageProfile(_ sender: Any) {
        
        self.tabBarController?.tabBar.isHidden = true
        let nextVC = Constants.StoryBoard.PROFILE.instantiateViewController(withIdentifier: "ManageProfileVC") as! ManageProfileVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onClickYourVoice(_ sender: Any) {
        
        self.tabBarController?.tabBar.isHidden = true
        let nextVC = Constants.StoryBoard.PROFILE.instantiateViewController(withIdentifier: "YourVoiceVC") as! YourVoiceVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onClickSaveCollection(_ sender: Any) {
        
        self.tabBarController?.tabBar.isHidden = true
        let nextVC = Constants.StoryBoard.PROFILE.instantiateViewController(withIdentifier: "SaveCollectionVC") as! SaveCollectionVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

    @IBAction func onClickYourDownload(_ sender: Any) {
        
        self.tabBarController?.tabBar.isHidden = true
        let nextVC = Constants.StoryBoard.PROFILE.instantiateViewController(withIdentifier: "YourDownloadsVC") as! YourDownloadsVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onClickTermsConditions(_ sender: Any) {
        
        self.tabBarController?.tabBar.isHidden = true
        let nextVC = Constants.StoryBoard.PROFILE.instantiateViewController(withIdentifier: "TermsConditionsVC") as! TermsConditionsVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onClickPrivacyPolicy(_ sender: Any) {
        
        self.tabBarController?.tabBar.isHidden = true
        let nextVC = Constants.StoryBoard.PROFILE.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onClickDeleteAccount(_ sender: Any) {
        
        let nextVC = Constants.StoryBoard.PROFILE.instantiateViewController(withIdentifier: "DeleteAccountVC") as! DeleteAccountVC
        self.tabBarController?.present(nextVC, animated: true)
    }
    
    @IBAction func onClickLogOut(_ sender: Any) {
        
        self.presentAlertWithCompletion(title: "Alert", message: "Are you sure want to Log Out?", options: ["No", "Yes"], optionStyle: [.default, .default]) { index in
            
            if index == 0 {
                
            }
            else {
                UserDefaults.standard.removeObject(forKey: "userInfo")
                UserDefaults.standard.removeObject(forKey: "userId")
                UserDefaults.standard.removeObject(forKey: "isLogin")
                UserDefaults.standard.removeObject(forKey: "isSocial")
                UserDefaults.standard.removeObject(forKey: "accesss_token")
                VoiceHandler.shared.arrayVoices.removeAll()
                GIDSignIn.sharedInstance.signOut()
                _appDelegate.makeRootView(rootVC: .Login)
            }
        }
    }
}
