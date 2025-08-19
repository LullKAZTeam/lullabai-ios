//
//  CustomFoodTabBar.swift
//  LullabAI
//
//  Created by Keyur Hirani on 16/01/25.
//

import UIKit

class CustomFoodTabBar: UIView {
    
    @IBOutlet var bgViews: [UIView]!
    @IBOutlet var imgViews: [UIImageView]!
    @IBOutlet var btnViews: [UIButton]!
    @IBOutlet var lblTitle: [UILabel]!
    
    var btnChangeItemCompletion: (_ index:Int) -> () = { index in }
    
    override func awakeFromNib() {
        hideAllVews()
        self.bgViews[0].isHidden = false
        self.lblTitle[0].isHidden = false
        self.imgViews[0].image = UIImage(named: "ic_TabHomeSelected")
    }
}

extension CustomFoodTabBar {

    @IBAction func btnClick(_ sender : UIButton) {
        
        hideAllVews()
        UIView.animate(withDuration: 0.2, delay: 0.0,options: .showHideTransitionViews,animations: {
            self.bgViews[sender.tag].isHidden = false
            self.lblTitle[sender.tag].isHidden = false
            switch sender.tag {
            case 0:
                self.imgViews[sender.tag].image = UIImage(named: "ic_TabHomeSelected")
            case 1:
                self.imgViews[sender.tag].image = UIImage(named: "ic_TabExploreSelected")
            case 2:
                self.imgViews[sender.tag].image = UIImage(named: "ic_TabHistorySelected")
            case 3:
                self.imgViews[sender.tag].image = UIImage(named: "ic_TabProfileSelected")
                if let userData = UserDefaults.standard.object(forKey: "userInfo") as? [String:Any], let userName = userData["name"] as? String {
                    
                    if let profile = userData["profile_image"] as? String, profile != "" {
                        self.imgViews[sender.tag].kf.setImage(with: URL(string: profile), placeholder: nil)
                    }
                }
            default:
                break
            }
        },completion: { status in
            self.btnChangeItemCompletion(sender.tag)
        })
    }
    
    func hideAllVews() {
        
        for i in 0..<btnViews.count {
            bgViews[i].isHidden = true
            lblTitle[i].isHidden = true
            switch i {
            case 0:
                imgViews[i].image = UIImage(named: "ic_TabHomeUnselected")
            case 1:
                imgViews[i].image = UIImage(named: "ic_TabExploreUnselected")
            case 2:
                imgViews[i].image = UIImage(named: "ic_TabHistoryUnselected")
            case 3:
                imgViews[i].image = UIImage(named: "ic_TabProfileUnselected")
                if let userData = UserDefaults.standard.object(forKey: "userInfo") as? [String:Any], let userName = userData["name"] as? String {
                    
                    if let profile = userData["profile_image"] as? String, profile != "" {
                        self.imgViews[i].kf.setImage(with: URL(string: profile), placeholder: nil)
                    }
                }
            default:
                break
            }
        }
    }
}

