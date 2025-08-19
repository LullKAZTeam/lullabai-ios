//
//  ManageProfileVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 22/01/25.
//

import UIKit

class ManageProfileVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var imgViewProfile: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let userData = UserDefaults.standard.object(forKey: "userInfo") as? [String:Any] {
            txtUsername.text = userData["name"] as? String
            txtEmail.text = userData["email"] as? String
            
            if let profile = userData["profile_image"] as? String, profile != "" {
                imgViewProfile.kf.setImage(with: URL(string: profile), placeholder: nil)
            }
            else {
                imgViewProfile.image = UIImage(named: "ic_ProfileHeader")
            }
        }
    }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickEditProfile(_ sender: Any) {
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: "", message: "Choose Image", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            
//            CameraPermissionHandler.shared.checkCameraPermission(isAskPermission: false) { success in
//                if success {
                    self.imagePicker.delegate = self
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.sourceType = .camera
                    self.present(self.imagePicker, animated: true, completion: nil)
//                }
//                else {
//                    let nextVC = Constants.StoryBoard.HOME.instantiateViewController(withIdentifier: "CameraPermissionVC") as! CameraPermissionVC
//                    self.tabBarController?.present(nextVC, animated: true)
//                }
            }
        //}
                                     ))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert) in
            
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (alert) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClickUpdateProfile(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let param: [String: Any] = [
            "name": txtUsername.text!
        ]
        
        let data = imgViewProfile.image?.jpegData(compressionQuality: 0.5) ?? Data()
        
        ApiHandler.shared.requestWithImage(.patch, methodName: .updateProfile, param: param, imageWithName: "profile_image", fileName: "profile.jpeg", imageMIMEType: "image/jpeg", image: data, vc: self, completion: { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any], let userData = data["user"] as? [String:Any] {
                    
                    var user = userData
                    for (key, value) in user {
                        if value is NSNull {
                            user[key] = ""
                        }
                    }
                    
                    UserDefaults.standard.setValue(user, forKey: "userInfo")
                    UserDefaults.standard.synchronize()
                }
                _appDelegate.makeRootView(rootVC: .Home)
            case .processing:
                break
            case .failed:
                if let data = json?["data"] as? [String:Any], let error = data["error"] as? String {
                    self.presentAlert(withTitle: "Oops!", message: error)
                }
            }
        })
    }
}

extension ManageProfileVC:UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let tempImage:UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        imgViewProfile.image  = tempImage
        imagePicker.dismiss(animated: true) {
        }
    }
}
