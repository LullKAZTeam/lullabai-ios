//
//  HomeVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 17/01/25.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgViewProfileHeader: UIImageView!
    
    var newStoryCointener: HomeNewStoryVC!
    var topPoemCointener: HomeTopPoemsVC!
    var sweetLullabiesCointener: HomeSweetLullabiesVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if let userData = UserDefaults.standard.object(forKey: "userInfo") as? [String:Any], let userName = userData["name"] as? String {
            lblUserName.text = userName
            
            if let profile = userData["profile_image"] as? String, profile != "" {
                imgViewProfileHeader.kf.setImage(with: URL(string: profile), placeholder: nil)
            }
            else {
                imgViewProfileHeader.image = UIImage(named: "ic_ProfileHeader")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeNewStoryVC" {
            newStoryCointener = segue.destination as? HomeNewStoryVC
        }
        else if segue.identifier == "HomeTopPoemsVC" {
            topPoemCointener = segue.destination as? HomeTopPoemsVC
        }
        else if segue.identifier == "HomeSweetLullabiesVC" {
            sweetLullabiesCointener = segue.destination as? HomeSweetLullabiesVC
        }
    }
}

extension HomeVC {
    
    func getStory() {
        
        _ = ApiHandler.shared.request(.get, for: .getHomeStory, param: nil, vc: self) { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any] {
                    
                    if let categoryList = data["featured"] as? [[String:Any]] {
                        self.newStoryCointener.arrayNewStory = categoryList
                    }
                    if let topPoemsList = data["recent"] as? [[String:Any]] {
                        self.topPoemCointener.arrayTopPoems = topPoemsList
                    }
                    if let topPoemsList = data["sweet"] as? [[String:Any]] {
                        self.sweetLullabiesCointener.arraySweet = topPoemsList
                    }
                    
                }
                self.newStoryCointener.collectionView.reloadData()
                self.topPoemCointener.collectionView.reloadData()
                self.sweetLullabiesCointener.collectionView.reloadData()
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

