//
//  CategoryHandler.swift
//  LullabAI
//
//  Created by Keyur Hirani on 03/02/25.
//

import Foundation

class CategoryHandler: NSObject {
    
    static let shared = CategoryHandler()
    
    var selectedExploreCategory = [String:Any]()
    var selectedExploreFiler = ""
    
    var arrayAllCategoryList: [[String:Any]] = []
    
    func geAlltCategory(complition:@escaping(Bool) -> ()) {
        
        if arrayAllCategoryList.count > 0 {
            complition(true)
        }
        else {
            _ = ApiHandler.shared.request(.get, for: .getCategoryList, param: nil, vc: nil) { status, json, error in
                
                switch status {
                case .success:
                    if let data = json?["data"] as? [String:Any], let categoryList = data["categories"] as? [[String:Any]] {
                        self.arrayAllCategoryList = categoryList
                        complition(true)
                    }
                    else {
                        complition(false)
                    }
                case .processing:
                    complition(false)
                    break
                case .failed:
                    
                    //                if let msg = json?["message"] as? String {
                    //                    self.presentAlert(withTitle: NSLocalizedString("Oops!", comment: ""), message: msg)
                    //                }
                    complition(false)
                }
            }
        }
    }
}
