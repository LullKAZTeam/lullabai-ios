//
//  HomeDefaultVoiceVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 17/01/25.
//

import UIKit

class HomeDefaultVoiceVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrayVoices = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        VoiceHandler.shared.getVoice { success in
            self.arrayVoices = VoiceHandler.shared.arrayVoices
            self.collectionView.reloadData()
        }
    }
}
extension HomeDefaultVoiceVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayVoices.count <= 1 ? arrayVoices.count+1 : arrayVoices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row < arrayVoices.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellHomeDefaultVoice", for: indexPath) as! cellHomeDefaultVoice
            cell.lblVoiceName.text = arrayVoices[indexPath.row]["name"] as? String
            cell.imgViewBg.kf.setImage(with: URL(string: arrayVoices[indexPath.row]["image"] as! String), placeholder: nil)
            cell.btnDelete.tag = indexPath.row
            cell.btnDelete.addTarget(self, action: #selector(onClickDeleteVoice(sender:)), for: .touchUpInside)
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellHomeAddVoice", for: indexPath) as! cellHomeAddVoice
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row < arrayVoices.count {
        }
        else {
            self.tabBarController?.tabBar.isHidden = true
            let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(identifier: "RecordVoiceVC") as! RecordVoiceVC
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @objc func onClickDeleteVoice(sender: UIButton) {
        
        self.presentAlertWithCompletion(title: "Alert", message: "Are you sure want to deltete this Audio?", options: ["No", "Yes"], optionStyle: [.default, .default]) { action in
            
            if action == 1 {
                self.deleteVoice(voiceId: "\(self.arrayVoices[sender.tag]["id"] ?? "")", index: sender.tag)
            }
        }
    }
}

class cellHomeDefaultVoice: UICollectionViewCell {
    
    @IBOutlet weak var imgViewBg: UIImageView!
    @IBOutlet weak var lblVoiceName: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
}

class cellHomeAddVoice: UICollectionViewCell {
    
}

extension HomeDefaultVoiceVC {
    
    func deleteVoice(voiceId: String, index: Int) {
        
        let param = ["voice": voiceId]
        
        _ = ApiHandler.shared.request(.delete, for: .deleteVoice, param: param, vc: self) { status, json, error in
            
            switch status {
            case .success:
                self.arrayVoices.remove(at: index)
                self.collectionView.reloadData()
                
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
