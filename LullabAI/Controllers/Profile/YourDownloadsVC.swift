//
//  YourDownloadsVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 21/01/25.
//

import UIKit

class YourDownloadsVC: UIViewController {
    
    @IBOutlet weak var collectionViewCategory: UICollectionView!
    @IBOutlet weak var consTrailingCancelSearch: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblHistory: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    
    var arrayCategory = [["image": UIImage(named: "ic_BackRound")!, "title": "Stories", "isSelected": true],
                         ["image": UIImage(named: "ic_BackRound")!, "title": "Poems", "isSelected": false],
                         ["image": UIImage(named: "ic_BackRound")!, "title": "Lullabies", "isSelected": false]]
    var arrayDownload = [[String:Any]]()
    var arrayFilterDownload = [[String:Any]]()
    var isFilter = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
        onClickCancelSearch(UIButton())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        var userId = ""
        if let userData = UserDefaults.standard.object(forKey: "userInfo") as? [String:Any] {
            userId = "\(userData["id"] ?? "")"
        }
        
        if let downloadData = UserDefaults.standard.object(forKey: "DownloadStory") as? [[String:Any]] {
            arrayDownload = downloadData.filter({"\($0["user_id"] ?? "")" == userId})
        }
        else {
            arrayDownload.removeAll()
        }
        self.tblHistory.reloadData()
        self.manageNoDataView()
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
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Get the current text from the text field
        let currentText = textField.text ?? ""
        print("Current text: \(currentText)")
        
        let predicate = NSPredicate(format: "story.title CONTAINS[c] %@", currentText)
        arrayFilterDownload = arrayDownload.filter { predicate.evaluate(with: $0) }
        
        if currentText == "" {
            isFilter = false
        }
        else {
            isFilter = true
        }
        
        tblHistory.reloadData()
        manageNoDataView()
    }
    
    func manageNoDataView() {
        
        if !isFilter && arrayDownload.count == 0 {
            lblNoData.isHidden = false
            tblHistory.isHidden = true
        }
        else {
            lblNoData.isHidden = true
            tblHistory.isHidden = false
        }
    }
}

extension YourDownloadsVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        consTrailingCancelSearch.constant = 18
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        return true
    }
}

extension YourDownloadsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellHomeCategories", for: indexPath)
        return cell
    }
}

extension YourDownloadsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFilter ? arrayFilterDownload.count : arrayDownload.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblHistory.dequeueReusableCell(withIdentifier: "cellTblHistory") as! cellTblHistory
        
        var historyData = [String:Any]()
        if isFilter {
            historyData = arrayFilterDownload[indexPath.row]
        }
        else {
            historyData = arrayDownload[indexPath.row]
        }
        
        if let story = historyData["story"] as? [String:Any] {
            cell.imgViewStory.kf.setImage(with: URL(string: story["image"] as! String), placeholder: nil)
            cell.lblStoryName.text = story["title"] as? String
        }
        cell.lblCategoryName.text = historyData["category"] as? String
        
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(onClickDelete(sender:)), for: .touchUpInside)
        
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(onClickPlay(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func onClickPlay(sender: UIButton) {
        let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(identifier: "PlayerVC") as! PlayerVC
        nextVC.arrayAudioData = isFilter ? arrayFilterDownload : arrayDownload
        nextVC.currentIndex = sender.tag
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func onClickDelete(sender: UIButton) {
        self.presentAlertWithCompletion(title: "Alert", message: "Are you sure want to remove this story from downloads?", options: ["No", "Yes"], optionStyle: [.default, .default]) { action in
            if action == 1 {
                
                var historyData = [String:Any]()
                if self.isFilter {
                    historyData = self.arrayFilterDownload[sender.tag]
                }
                else {
                    historyData = self.arrayDownload[sender.tag]
                }
                
                if let downloadData = UserDefaults.standard.object(forKey: "DownloadStory") as? [[String:Any]] {
                    
                    var userId = ""
                    if let userData = UserDefaults.standard.object(forKey: "userInfo") as? [String:Any] {
                        userId = "\(userData["id"] ?? "")"
                    }
                    
                    var data:[[String:Any]] = downloadData
                    data.removeAll(where: {("\($0["id"] ?? "")" == "\(historyData["id"] ?? "")") && ("\($0["user_id"] ?? "")" == userId)})
                    UserDefaults.standard.set(data, forKey: "DownloadStory")
                    UserDefaults.standard.synchronize()
                    
                    self.arrayDownload.removeAll(where: {"\($0["id"] ?? "")" == "\(historyData["id"] ?? "")"})
                    self.arrayFilterDownload.removeAll(where: {"\($0["id"] ?? "")" == "\(historyData["id"] ?? "")"})
                    self.tblHistory.reloadData()
                    self.manageNoDataView()
                }
            }
        }
    }
}

