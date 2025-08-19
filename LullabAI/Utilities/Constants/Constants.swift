//
//  Constants.swift
//  LullabAI
//
//  Created by Keyur Hirani on 20/01/25.
//

import UIKit
import Foundation

let _appDelegate            = UIApplication.shared.delegate as! AppDelegate

struct Constants {
 
    struct StoryBoard {
        static let HOME             = UIStoryboard(name: "Home", bundle: nil)
        static let EXPLORE          = UIStoryboard(name: "Explore", bundle: nil)
        static let HISTORY          = UIStoryboard(name: "History", bundle: nil)
        static let PROFILE          = UIStoryboard(name: "Profile", bundle: nil)
        static let MAIN             = UIStoryboard(name: "Main", bundle: nil)
    }
}
