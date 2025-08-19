//
//  UIViewController_Extensions.swift
//  LullabAI
//
//  Created by Keyur Hirani on 24/01/25.
//

import Foundation
import UIKit

extension UIViewController {
    func presentAlert(withTitle title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { action in
            print("You've pressed OK Button")
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentAlertWithCompletion(title: String, message: String, options: [String],optionStyle: [UIAlertAction.Style], completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for i in 0..<options.count {
            alertController.addAction(UIAlertAction.init(title: options[i], style: optionStyle[i], handler: { (action) in
                completion(i)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
