//
//  ExploreVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 17/01/25.
//

import UIKit

class ExploreVC: UIViewController {

    @IBOutlet weak var collectionViewCategory: UICollectionView!
    @IBOutlet weak var collectionViewList: UICollectionView!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var lblFilterName: UILabel!
    @IBOutlet weak var consTrailingCancelSearch: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var imgViewProfileHeader: UIImageView!
    
    var arrayCategory = [[String:Any]]()
    var arrayExplore = [[String:Any]]()
    var arrayFilterExplore = [[String:Any]]()
    var isFilter = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setFilterMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if CategoryHandler.shared.selectedExploreFiler != "" {
            self.lblFilterName.text = CategoryHandler.shared.selectedExploreFiler
            CategoryHandler.shared.selectedExploreFiler = ""
        }
        
        if arrayCategory.count == 0 {
            getCategory()
        }
        else {
            collectionViewCategory.reloadData()
            getExploreList()
        }
        
        if let userData = UserDefaults.standard.object(forKey: "userInfo") as? [String:Any], let userName = userData["name"] as? String {
            
            if let profile = userData["profile_image"] as? String, profile != "" {
                imgViewProfileHeader.kf.setImage(with: URL(string: profile), placeholder: nil)
            }
            else {
                imgViewProfileHeader.image = UIImage(named: "ic_ProfileHeader")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
        lblFilterName.text = "All Stories"
        onClickCancelSearch(UIButton())
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Get the current text from the text field
        let currentText = textField.text ?? ""
        print("Current text: \(currentText)")
        
        let predicate = NSPredicate(format: "title CONTAINS[c] %@", currentText)
        arrayFilterExplore = arrayExplore.filter { predicate.evaluate(with: $0) }
        
        if currentText == "" {
            isFilter = false
        }
        else {
            isFilter = true
        }
        
        collectionViewList.reloadData()
    }
    
    @IBAction func onClickCancelSearch(_ sender: Any) {
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        
        consTrailingCancelSearch.constant = -50
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onClickFilter(_ sender: Any) {
    }
    
    func setFilterMenu() {
        
        let all = UIAction(title: "All Stories") { (action) in
            self.lblFilterName.text = action.title
            self.getExploreList()
        }
        
        let Latest = UIAction(title: "Latest stories") { (action) in
            self.lblFilterName.text = action.title
            self.getExploreList()
        }
        
        let Featured = UIAction(title: "Featured stories") { (action) in
            self.lblFilterName.text = action.title
            self.getExploreList()
        }
        
        let Suggested = UIAction(title: "Suggested stories") { (action) in
            self.lblFilterName.text = action.title
            self.getExploreList()
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: [all, Latest , Featured, Suggested])
        
        btnFilter.menu = menu
        btnFilter.showsMenuAsPrimaryAction = true
    }
}

extension ExploreVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        consTrailingCancelSearch.constant = 18
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        return true
    }
}

extension ExploreVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == collectionViewCategory {
            return arrayCategory.count
        }
        else {
            return isFilter ? arrayFilterExplore.count : arrayExplore.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionViewCategory {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCategory", for: indexPath) as! cellCategory
            cell.imgViewIcon.kf.setImage(with: URL(string: arrayCategory[indexPath.row]["image"] as! String), placeholder: nil)
            cell.lblTitle.text = arrayCategory[indexPath.row]["name"] as? String
            
            if "\(arrayCategory[indexPath.row]["name"] ?? "")" == "All" {
                cell.imgViewIcon.isHidden = true
            }
            
            if "\(arrayCategory[indexPath.row]["id"] ?? "")" == "\(CategoryHandler.shared.selectedExploreCategory["id"] ?? "")" {
                cell.viewBG.backgroundColor = UIColor("9D9FE6")
                cell.lblTitle.textColor = .white
            }
            else {
                cell.viewBG.backgroundColor = .white
                cell.lblTitle.textColor = UIColor("808080")
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellExploreList", for: indexPath) as! cellExploreList
            
            var exploreData = [String:Any]()
            if isFilter {
                exploreData = arrayFilterExplore[indexPath.row]
            }
            else {
                exploreData = arrayExplore[indexPath.row]
            }
            
            cell.imgViewStory.kf.setImage(with: URL(string: exploreData["image"] as! String), placeholder: nil)
            cell.lblStoryName.text = exploreData["title"] as? String
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionViewCategory {
            if "\(arrayCategory[indexPath.row]["name"] ?? "")" == "All" {
                return CGSize(width: 150, height: 40)
            }
            let text = arrayCategory[indexPath.row]["name"] as! String
            let height = 40.0
            let width = text.size(usingFont:UIFont(name: "Nunito SemiBold", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)).width + 53
            
            return CGSize(width: width, height: height)
        }
        else {
            return CGSize(width: (collectionView.frame.size.width/3), height: (collectionView.frame.size.width/3)+37)
            //return CGSize(width: 50, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == collectionViewCategory {
            CategoryHandler.shared.selectedExploreCategory = arrayCategory[indexPath.row]
            collectionView.reloadData()
            
            arrayExplore.removeAll()
            collectionViewList.reloadData()
            getExploreList()
        }
        else {
            self.tabBarController?.tabBar.isHidden = true
            let nextVC = Constants.StoryBoard.HOME.instantiateViewController(identifier: "CreateVoiceVC") as! CreateVoiceVC
            nextVC.storyData = arrayExplore[indexPath.row]
            nextVC.delegate = self
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}

class cellCategory: UICollectionViewCell {
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
}

class cellExploreList: UICollectionViewCell {
    @IBOutlet weak var imgViewStory: UIImageView!
    @IBOutlet weak var lblStoryName: UILabel!
}


extension ExploreVC {
    
    func getCategory() {
        
        CategoryHandler.shared.geAlltCategory { success in
            if success {
                let allCategory: [String:Any] = ["id": "", "name": "All", "image": ""]
                self.arrayCategory.append(allCategory)
                if CategoryHandler.shared.selectedExploreCategory.keys.count == 0 {
                    CategoryHandler.shared.selectedExploreCategory = allCategory
                }
                
                for i in 0..<CategoryHandler.shared.arrayAllCategoryList.count {
                    self.arrayCategory.append(CategoryHandler.shared.arrayAllCategoryList[i])
                }
            }
            self.collectionViewCategory.reloadData()
            self.getExploreList()
        }
        
//        _ = ApiHandler.shared.request(.get, for: .getCategoryList, param: nil, vc: nil) { status, json, error in
//            
//            switch status {
//            case .success:
//                if let data = json?["data"] as? [String:Any], let categoryList = data["categories"] as? [[String:Any]] {
//                    
//                    let allCategory: [String:Any] = ["id": "", "name": "All", "image": ""]
//                    self.arrayCategory.append(allCategory)
//                    if CategoryHandler.shared.selectedExploreCategory.keys.count == 0 {
//                        CategoryHandler.shared.selectedExploreCategory = allCategory
//                    }
//                    
//                    for i in 0..<categoryList.count {
//                        self.arrayCategory.append(categoryList[i])
//                    }
//                }
//            case .processing:
//                break
//            case .failed:
//                
//                if let msg = json?["message"] as? String {
//                    self.presentAlert(withTitle: NSLocalizedString("Oops!", comment: ""), message: msg)
//                }
//            }
//            self.collectionViewCategory.reloadData()
//            
//            self.getExploreList()
//        }
        
    }
    
    func getExploreList() {
        
        var param = [String:Any]()
        
        if "\(CategoryHandler.shared.selectedExploreCategory["id"] ?? "")" != "" {
            param["category"] = "\(CategoryHandler.shared.selectedExploreCategory["id"] ?? "")"
        }
        
        if lblFilterName.text! == "Latest stories" {
            param["type"] = "1"
        }
        else if lblFilterName.text! == "Featured stories" {
            param["type"] = "2"
        }
        else if lblFilterName.text! == "Suggested stories" {
            param["type"] = "3"
        }
        
        _ = ApiHandler.shared.request(for: .getStory, param: param.keys.count > 0 ? param : nil, vc: nil) { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any], let historyList = data["stories"] as? [[String:Any]] {
                    self.arrayExplore = historyList
                }
            case .processing:
                break
            case .failed:
                
                if let msg = json?["message"] as? String {
                    self.presentAlert(withTitle: NSLocalizedString("Oops!", comment: ""), message: msg)
                }
            }
            self.textFieldDidChange(self.txtSearch)
        }
    }
}

extension ExploreVC: CreateVoiceVCDelegate {
    func createVoiceDidFinish() {
        NotificationCenter.default.post(name: NSNotification.Name("ChangeTab"), object: ["selectedTab":2])
    }
}
