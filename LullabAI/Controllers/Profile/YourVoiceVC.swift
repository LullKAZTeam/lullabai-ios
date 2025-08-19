//
//  YourVoiceVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 13/02/25.
//

import UIKit

class YourVoiceVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    
    var arrayVoices = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        VoiceHandler.shared.getVoice { success in
            self.arrayVoices = VoiceHandler.shared.arrayVoices
            self.tblView.reloadData()
            self.manageNoDataView()
        }
    }
    

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func manageNoDataView() {
        
        if arrayVoices.count == 0 {
            lblNoData.isHidden = false
            tblView.isHidden = true
        }
        else {
            lblNoData.isHidden = true
            tblView.isHidden = false
        }
    }
}

extension YourVoiceVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return arrayVoices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourVoicecell") as! YourVoicecell
        cell.lblTitle.text = arrayVoices[indexPath.row]["name"] as? String
        cell.imgViewIcon.kf.setImage(with: URL(string: arrayVoices[indexPath.row]["image"] as! String), placeholder: nil)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(onClickDeleteVoice(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func onClickDeleteVoice(sender: UIButton) {
        
        self.presentAlertWithCompletion(title: "Alert", message: "Are you sure want to deltete this Audio?", options: ["No", "Yes"], optionStyle: [.default, .default]) { action in
            
            if action == 1 {
                self.deleteVoice(voiceId: "\(self.arrayVoices[sender.tag]["id"] ?? "")", index: sender.tag)
            }
        }
    }
}

class YourVoicecell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
}

extension YourVoiceVC {
    
    func deleteVoice(voiceId: String, index: Int) {
        
        let param = ["voice": voiceId]
        
        _ = ApiHandler.shared.request(.delete, for: .deleteVoice, param: param, vc: self) { status, json, error in
            
            switch status {
            case .success:
                self.arrayVoices.remove(at: index)
                self.tblView.reloadData()
                self.manageNoDataView()
                
                VoiceHandler.shared.getVoice { success in
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
