//
//  PrivacyPolicyVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 22/01/25.
//

import UIKit
import WebKit

class PrivacyPolicyVC: UIViewController {

    @IBOutlet weak var textViewPolicy: UITextView!
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        getPrivacyPolicy()
    }
    

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PrivacyPolicyVC {
    
    func getPrivacyPolicy() {
        
        let param = ["type": "policy"]
        
        _ = ApiHandler.shared.request(for: .getPrivacyPolicy, param: param, vc: self) { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any], let story = data["story"] as? [String:Any] {
                    //self.textViewPolicy.text = story["file"] as? String ?? ""
                    
                    let link = URL(string:story["file"] as? String ?? "")!
                    let request = URLRequest(url: link)
                    self.webView.load(request)
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
