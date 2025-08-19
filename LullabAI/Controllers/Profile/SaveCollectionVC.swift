//
//  SaveCollectionVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 20/01/25.
//

import UIKit

class SaveCollectionVC: UIViewController {
    
    @IBOutlet weak var collectionViewCategory: UICollectionView!
    @IBOutlet weak var consTrailingCancelSearch: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblHistory: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    
    var arrayCategory = [["image": UIImage(named: "ic_BackRound")!, "title": "Stories", "isSelected": true],
                         ["image": UIImage(named: "ic_BackRound")!, "title": "Poems", "isSelected": false],
                         ["image": UIImage(named: "ic_BackRound")!, "title": "Lullabies", "isSelected": false]]
    
    var arrayBookmark = [[String:Any]]()
    var arrayFilterBookmark = [[String:Any]]()
    var isFilter = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
        onClickCancelSearch(UIButton())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBookmarkList()
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
        arrayFilterBookmark = arrayBookmark.filter { predicate.evaluate(with: $0) }
        
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
        
        if !isFilter && arrayBookmark.count == 0 {
            lblNoData.isHidden = false
            tblHistory.isHidden = true
        }
        else {
            lblNoData.isHidden = true
            tblHistory.isHidden = false
        }
    }
}

extension SaveCollectionVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        consTrailingCancelSearch.constant = 18
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        return true
    }
}

extension SaveCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellHomeCategories", for: indexPath)
        return cell
    }
}

extension SaveCollectionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFilter ? arrayFilterBookmark.count : arrayBookmark.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblHistory.dequeueReusableCell(withIdentifier: "cellTblHistory") as! cellTblHistory
        
        var historyData = [String:Any]()
        if isFilter {
            historyData = arrayFilterBookmark[indexPath.row]
        }
        else {
            historyData = arrayBookmark[indexPath.row]
        }
        
        if let story = historyData["story"] as? [String:Any] {
            cell.imgViewStory.kf.setImage(with: URL(string: story["image"] as! String), placeholder: nil)
            cell.lblStoryName.text = story["title"] as? String
        }
        cell.lblCategoryName.text = historyData["category"] as? String
        
        cell.btnBookmark.tag = indexPath.row
        cell.btnBookmark.addTarget(self, action: #selector(onClickBookmark(sender:)), for: .touchUpInside)
        
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(onClickPlay(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func onClickBookmark(sender: UIButton) {
        RemoveBookmark(index: sender.tag)
    }
    
    @objc func onClickPlay(sender: UIButton) {
        let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(identifier: "PlayerVC") as! PlayerVC
        nextVC.arrayAudioData = isFilter ? arrayFilterBookmark : arrayBookmark
        nextVC.currentIndex = sender.tag
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension SaveCollectionVC {
    
    func getBookmarkList() {
        
        let param: [String: Any] = ["title":""]
        _ = ApiHandler.shared.request(for: .getMookmarkList, param: param, vc: self) { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any], let historyList = data["history"] as? [[String:Any]] {
                    self.arrayBookmark = historyList
                }
            case .processing:
                break
            case .failed:
                
                if let msg = json?["message"] as? String {
                    self.presentAlert(withTitle: NSLocalizedString("Oops!", comment: ""), message: msg)
                }
            }
            self.tblHistory.reloadData()
            self.manageNoDataView()
        }
    }
    
    func RemoveBookmark(index:Int) {
        
        var historyData = [String:Any]()
        if isFilter {
            historyData = arrayFilterBookmark[index]
        }
        else {
            historyData = arrayBookmark[index]
        }
        
        let param = ["history": "\(historyData["id"] ?? "")", "flag": "0"] as [String : Any]
        
        _ = ApiHandler.shared.request(for: .bookmarkStory, param: param.keys.count > 0 ? param : nil, vc: self) { status, json, error in
            
            switch status {
            case .success:
                self.arrayBookmark.removeAll(where: {$0["id"] as? String == historyData["id"] as? String})
                self.arrayFilterBookmark.removeAll(where: {$0["id"] as? String == historyData["id"] as? String})
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
