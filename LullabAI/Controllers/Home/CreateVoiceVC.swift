//
//  CreateVoiceVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 31/01/25.
//

import UIKit

protocol CreateVoiceVCDelegate: AnyObject {
    func createVoiceDidFinish()
}

class CreateVoiceVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewVoiceIcon: UIImageView!
    @IBOutlet weak var lblVoiceName: UILabel!
    @IBOutlet weak var imgViewStoryIcon: UIImageView!
    @IBOutlet weak var lblStoryTitle: UILabel!
    @IBOutlet weak var lblStorySubTitle: UILabel!
    @IBOutlet weak var textStory: UITextView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet weak var txtVoice: UITextField!
    
    var storyData = [String:Any]()
    var arrayVoice = [[String:Any]]()
    var selectedVoice = [String:Any]()
    weak var delegate: CreateVoiceVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtVoice.inputView = pickerView
        print(storyData)
        imgViewStoryIcon.kf.setImage(with: URL(string: storyData["image"] as! String), placeholder: nil)
        lblTitle.text = storyData["title"] as? String
        lblStoryTitle.text = storyData["title"] as? String
        lblStorySubTitle.text = storyData["category"] as? String
        textStory.text = storyData["story"] as? String
        
        arrayVoice = VoiceHandler.shared.arrayVoices
        
        if arrayVoice.count > 0 {
            lblVoiceName.text = arrayVoice[0]["name"] as? String
            selectedVoice = arrayVoice[0]
        }
    }
}
extension CreateVoiceVC {
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickVoice(_ sender: Any) {
        txtVoice.becomeFirstResponder()
    }
    
    @IBAction func onClickGenerate(_ sender: Any) {
        self.view.endEditing(true)
        if lblVoiceName.text! == "" {
            self.presentAlert(withTitle: "Oops!", message: "Please select voice.")
        }
        else {
            generateVoice()
        }
    }
}

extension CreateVoiceVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayVoice.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return arrayVoice[row]["name"] as? String ?? ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        lblVoiceName.text = arrayVoice[row]["name"] as? String
        selectedVoice = arrayVoice[row]
    }
}

extension CreateVoiceVC {
    
    func generateVoice() {
        
        let param = ["story":"\(storyData["id"] ?? "")",
                     "voice": "\(selectedVoice["id"] ?? "")"]
        
        _ = ApiHandler.shared.request(for: .generateVoice, param: param, vc: self) { status, json, error in
            
            switch status {
            case .success:
                self.presentAlertWithCompletion(title: "Success", message: "Voice generate request submited successfully", options: ["OK"], optionStyle: [.default]) { action in
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.createVoiceDidFinish()
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
