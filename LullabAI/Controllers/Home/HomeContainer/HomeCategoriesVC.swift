//
//  HomeCategoriesVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 17/01/25.
//

import UIKit
import Kingfisher

class HomeCategoriesVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrayCategoryList = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getCategory()
    }
}

extension HomeCategoriesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayCategoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellHomeCategories", for: indexPath) as! cellHomeCategories
        cell.imgViewCategory.kf.setImage(with: URL(string: arrayCategoryList[indexPath.row]["image"] as! String), placeholder: nil)
        cell.lblTitle.text = arrayCategoryList[indexPath.row]["name"] as? String
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CategoryHandler.shared.selectedExploreCategory = arrayCategoryList[indexPath.row]
        NotificationCenter.default.post(name: NSNotification.Name("ChangeTab"), object: ["selectedTab":1])
    }
}

class cellHomeCategories: UICollectionViewCell {
    
    @IBOutlet weak var imgViewCategory: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
}

extension HomeCategoriesVC {
    
    func getCategory() {
        
        CategoryHandler.shared.geAlltCategory { success in
            self.arrayCategoryList = CategoryHandler.shared.arrayAllCategoryList
            self.collectionView.reloadData()
        }
//        _ = ApiHandler.shared.request(.get, for: .getCategoryList, param: nil, vc: nil) { status, json, error in
//            
//            switch status {
//            case .success:
//                if let data = json?["data"] as? [String:Any], let categoryList = data["categories"] as? [[String:Any]] {
//                    self.arrayCategoryList = categoryList
//                }
//                
//            case .processing:
//                break
//            case .failed:
//                
//                if let msg = json?["message"] as? String {
//                    self.presentAlert(withTitle: NSLocalizedString("Oops!", comment: ""), message: msg)
//                }
//            }
//            self.collectionView.reloadData()
//        }
    }
}
