//
//  HomeNewStoryVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 17/01/25.
//

import UIKit

class HomeNewStoryVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrayNewStory = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickViewAll(_ sender: Any) {
        CategoryHandler.shared.selectedExploreCategory = ["id": "", "name": "All", "image": ""]
        CategoryHandler.shared.selectedExploreFiler = "Featured stories"
        NotificationCenter.default.post(name: NSNotification.Name("ChangeTab"), object: ["selectedTab":1])
    }
}

extension HomeNewStoryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayNewStory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellHomeNewStory", for: indexPath) as! cellHomeNewStory
        cell.imgViewIcon.kf.setImage(with: URL(string: arrayNewStory[indexPath.row]["image"] as! String), placeholder: nil)
        cell.lblTitle.text = arrayNewStory[indexPath.row]["title"] as? String
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.tabBarController?.tabBar.isHidden = true
        let nextVC = Constants.StoryBoard.HOME.instantiateViewController(identifier: "CreateVoiceVC") as! CreateVoiceVC
        nextVC.storyData = arrayNewStory[indexPath.row]
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

class cellHomeNewStory: UICollectionViewCell {
    
    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
}


extension HomeNewStoryVC: CreateVoiceVCDelegate {
    func createVoiceDidFinish() {
        NotificationCenter.default.post(name: NSNotification.Name("ChangeTab"), object: ["selectedTab":2])
    }
}
