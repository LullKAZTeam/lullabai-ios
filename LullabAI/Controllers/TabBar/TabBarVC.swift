//
//  TabBarVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 16/01/25.
//

import UIKit

class TabBarVC: UITabBarController {

    var customView:CustomFoodTabBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeTab(notification: )), name: NSNotification.Name("ChangeTab"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProScreen(_:)), name: NSNotification.Name("showProScreen"), object: nil)
    }
    
    @objc func changeTab(notification: Notification) {
        if let info = notification.object as? [String:Any] {
            let index = info["selectedTab"] as? Int ?? 0
            
            customView?.hideAllVews()
            customView?.bgViews[index].isHidden = false
            customView?.lblTitle[index].isHidden = false
            self.selectedIndex = index
            
            let btnTemp = UIButton()
            btnTemp.tag = index
            customView.btnClick(btnTemp)
        }
    }
    
    @objc func showProScreen(_ notification: Notification) {
//        let nextVC = Constants.StoryBoard.INTRO.instantiateViewController(withIdentifier: "UpgradeToProNewVC") as! UpgradeToProNewVC
//        nextVC.isFrom = "Home"
//        self.present(nextVC, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        tabBar.frame.size.height = 95
//        tabBar.frame.origin.y = view.frame.height - 95
        
        let window = UIApplication.shared.keyWindowInConnectedScenes
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        if !UIDevice.current.isNotch {
            
            tabBar.frame.size.height = 80 + bottomPadding
            tabBar.frame.origin.y = view.frame.height - 80 - bottomPadding
        }
    }
}

extension TabBarVC {
    
    func setupUI() {
        
        customView = Bundle.main.loadNibNamed("CustomFoodTabBar", owner: nil, options: nil)?.first as? CustomFoodTabBar
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.btnChangeItemCompletion = {value in
            self.selectedIndex = value
        }
        self.tabBar.addSubview(customView)
        self.tabBar.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            customView.widthAnchor.constraint(equalTo: tabBar.widthAnchor,constant: 0),
            customView.heightAnchor.constraint(equalTo: tabBar.heightAnchor,constant:0),
            customView.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor,constant: 0),
            customView.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor,constant: 0)
        ])
    }
}
extension UIApplication {
    
    /// The app's key window.
    var keyWindowInConnectedScenes: UIWindow? {
        let windowScenes: [UIWindowScene] = connectedScenes.compactMap({ $0 as? UIWindowScene })
        let windows: [UIWindow] = windowScenes.flatMap({ $0.windows })
        return windows.first(where: { $0.isKeyWindow })
    }
    
}

extension UIDevice {
    /// Returns `true` if the device has a notch
    var isNotch: Bool {
        let window = UIApplication.shared.keyWindowInConnectedScenes
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        if bottomPadding == 0 {
            return false
        }
        return true
    }
}
