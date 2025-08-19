//
//  HistoryVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 17/01/25.
//

import UIKit

class HistoryVC: UIViewController {
    
    @IBOutlet weak var collectionViewCategory: UICollectionView!
    @IBOutlet weak var consTrailingCancelSearch: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblHistory: UITableView!
    @IBOutlet weak var imgViewProfileHeader: UIImageView!
    @IBOutlet weak var lblNoData: UILabel!
    
    var arrayCategory = [[String:Any]]()
    var selectedCategory = [String:Any]()
    var arrayHistory = [[String:Any]]()
    var arrayFilterHistory = [[String:Any]]()
    var isFilter = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if arrayCategory.count == 0 {
            getCategory()
        }
        else {
            getHistory()
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
    
        onClickCancelSearch(UIButton())
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Get the current text from the text field
        let currentText = textField.text ?? ""
        print("Current text: \(currentText)")
        
        let predicate = NSPredicate(format: "story.title CONTAINS[c] %@", currentText)
        arrayFilterHistory = arrayHistory.filter { predicate.evaluate(with: $0) }
        
        if currentText == "" {
            isFilter = false
        }
        else {
            isFilter = true
        }
        
        tblHistory.reloadData()
        manageNoDataView()
    }
    
    @IBAction func onClickRefresh(_ sender: Any) {
        getHistory(isLoading: true)
    }
    
    @IBAction func onClickCancelSearch(_ sender: Any) {
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        
        consTrailingCancelSearch.constant = -50
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        isFilter = false
        tblHistory.reloadData()
        manageNoDataView()
    }
    
    func manageNoDataView() {
        
        if !isFilter && arrayHistory.count == 0 {
            lblNoData.isHidden = false
            tblHistory.isHidden = true
        }
        else {
            lblNoData.isHidden = true
            tblHistory.isHidden = false
        }
    }
}

extension HistoryVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        consTrailingCancelSearch.constant = 18
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        return true
    }
}

extension HistoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrayCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCategory", for: indexPath) as! cellCategory
        cell.imgViewIcon.kf.setImage(with: URL(string: arrayCategory[indexPath.row]["image"] as! String), placeholder: nil)
        cell.lblTitle.text = arrayCategory[indexPath.row]["name"] as? String
        
        if "\(arrayCategory[indexPath.row]["name"] ?? "")" == "All" {
            cell.imgViewIcon.isHidden = true
        }
        if arrayCategory[indexPath.row]["isSelected"] as! Bool {
            cell.viewBG.backgroundColor = UIColor("9D9FE6")
            cell.lblTitle.textColor = .white
        }
        else {
            cell.viewBG.backgroundColor = .white
            cell.lblTitle.textColor = UIColor("808080")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if "\(arrayCategory[indexPath.row]["name"] ?? "")" == "All" {
            return CGSize(width: 150, height: 40)
        }
        let text = arrayCategory[indexPath.row]["name"] as! String
        let height = 40.0
        let width = text.size(usingFont:UIFont(name: "Nunito SemiBold", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)).width + 53
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for i in 0..<arrayCategory.count {
            if i == indexPath.row {
                arrayCategory[i]["isSelected"] = true
                self.selectedCategory = arrayCategory[i]
            }
            else {
                arrayCategory[i]["isSelected"] = false
            }
        }
        collectionView.reloadData()
        
        arrayHistory.removeAll()
        tblHistory.reloadData()
        manageNoDataView()
        getHistory()
    }
}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFilter ? arrayFilterHistory.count : arrayHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblHistory.dequeueReusableCell(withIdentifier: "cellTblHistory") as! cellTblHistory
        
        var historyData = [String:Any]()
        if isFilter {
            historyData = arrayFilterHistory[indexPath.row]
        }
        else {
            historyData = arrayHistory[indexPath.row]
        }
        
        if let story = historyData["story"] as? [String:Any] {
            cell.imgViewStory.kf.setImage(with: URL(string: story["image"] as! String), placeholder: nil)
            cell.lblStoryName.text = story["title"] as? String
        }
        
        if let voice = historyData["voice"] as? [String:Any] {
            cell.imgViewVoice.kf.setImage(with: URL(string: voice["image"] as! String), placeholder: nil)
            cell.lblVoiceName.text = voice["name"] as? String
        }
        
//        if let url = historyData["ai_voice"] as? String {
//            //cell.lblTime.text = historyData["created_at"] as? String
//            cell.lblTime.text = dateFormate(date: historyData["created_at"] as? String ?? "")
//        }
//        else {
//            cell.lblTime.text = "In progress"
//        }
        
        let voiceStatus = Int("\(historyData["gen_status"] ?? "0")")
        cell.lblTime.textColor = UIColor.init("808080")
        if voiceStatus == 1 {
            cell.lblTime.text = "In progress"
        }
        else if voiceStatus == 2 {
            cell.lblTime.text = dateFormate(date: historyData["created_at"] as? String ?? "")
        }
        else {
            cell.lblTime.text = "Failed"
            cell.lblTime.textColor = .red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            
            self.deleteHistory(index: indexPath.row)
            completionHandler(true)
        }
        deleteAction.image = UIImage(named: "ic_DeleteIcon")// UIImage(systemName: "ic_CategoryPoems")
        deleteAction.backgroundColor = UIColor.init("F6F6F6")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var historyData = [String:Any]()
        if isFilter {
            historyData = arrayFilterHistory[indexPath.row]
        }
        else {
            historyData = arrayHistory[indexPath.row]
        }
        
        let voiceStatus = Int("\(historyData["gen_status"] ?? "0")")
        if voiceStatus == 1 {
            self.presentAlert(withTitle: "Oops!", message: "Your story is being generating. Please wait a moment.")
        }
        else if voiceStatus == 2 {
            self.tabBarController?.tabBar.isHidden = true
            let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(identifier: "PlayerVC") as! PlayerVC
            nextVC.arrayAudioData = isFilter ? arrayFilterHistory : arrayHistory
            nextVC.currentIndex = indexPath.row
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        else {
            self.presentAlert(withTitle: "Oops!", message: "We couldn't generate your story. Please try again later.")
        }
    }
}

class cellTblHistory: UITableViewCell {
    
    @IBOutlet weak var imgViewStory: UIImageView!
    @IBOutlet weak var lblStoryName: UILabel!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var imgViewVoice: UIImageView!
    @IBOutlet weak var lblVoiceName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnBookmark: UIButton!
}

extension HistoryVC {
    
    func getCategory() {
        
        CategoryHandler.shared.geAlltCategory { success in
            if success {
                let allCategory: [String:Any] = ["id": "", "name": "All", "isSelected": true, "image": ""]
                self.arrayCategory.append(allCategory)
                self.selectedCategory = allCategory
                
                for i in 0..<CategoryHandler.shared.arrayAllCategoryList.count {
                    var category = CategoryHandler.shared.arrayAllCategoryList[i]
                    category["isSelected"] = false
                    self.arrayCategory.append(category)
                }
            }
            
            self.collectionViewCategory.reloadData()
            self.getHistory()
        }
        
//        _ = ApiHandler.shared.request(.get, for: .getCategoryList, param: nil, vc: nil) { status, json, error in
//            
//            switch status {
//            case .success:
//                if let data = json?["data"] as? [String:Any], let categoryList = data["categories"] as? [[String:Any]] {
//                    
//                    let allCategory: [String:Any] = ["id": "", "name": "All", "isSelected": true, "image": ""]
//                    self.arrayCategory.append(allCategory)
//                    self.selectedCategory = allCategory
//                    
//                    for i in 0..<categoryList.count {
//                        var category = categoryList[i]
//                        category["isSelected"] = false
//                        self.arrayCategory.append(category)
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
//            self.getHistory()
//        }
        
    }
    
    func getHistory(isLoading:Bool = false) {
        
        var param = [String:Any]()
        
        if "\(selectedCategory["id"] ?? "")" != "" {
            param["category"] = "\(selectedCategory["id"] ?? "")"
        }
        
        _ = ApiHandler.shared.request(for: .getHistory, param: param.keys.count > 0 ? param : nil, vc: isLoading ? self : nil) { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any], let historyList = data["history"] as? [[String:Any]] {
                    
                    let sortedItems = historyList.sorted { first, second in
                        // Convert `created_at` strings to Date
                        let dateFormatter = ISO8601DateFormatter()
                        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        guard
                            let date1String = first["created_at"] as? String,
                                    let date2String = second["created_at"] as? String,
                                    let date1 = dateFormatter.date(from: date1String),
                                    let date2 = dateFormatter.date(from: date2String)
                        else {
                            return false
                        }
                        
                        return date1 > date2
                    }
                    self.arrayHistory = sortedItems
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
    
    func deleteHistory(index: Int) {
        
        var historyId = ""
        
        if isFilter {
            historyId = "\(self.arrayFilterHistory[index]["id"] ?? "")"
        }
        else {
            historyId = "\(self.arrayHistory[index]["id"] ?? "")"
        }
        
        self.presentAlertWithCompletion(title: "Alert", message: "Are you sure want to deltete this Story?", options: ["No", "Yes"], optionStyle: [.default, .default]) { action in
            
            if action == 1 {
                
                let param = ["history": historyId]
                
                _ = ApiHandler.shared.request(.delete, for: .deleteHistory, param: param, vc: self) { status, json, error in
                    
                    switch status {
                    case .success:
                        
                        self.arrayHistory.removeAll { record in
                            return "\(record["id"] ?? "")" == historyId
                        }
                        
                        self.arrayFilterHistory.removeAll { record in
                            return "\(record["id"] ?? "")" == historyId
                        }
                        
                        self.tblHistory.reloadData()
                        self.manageNoDataView()
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
    }
}

extension HistoryVC {
    
    func dateFormate(date: String) -> String {
     
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: date) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate // Output: "02/17/2025 04:01 PM"
        } else {
            return date
        }
    }
}
