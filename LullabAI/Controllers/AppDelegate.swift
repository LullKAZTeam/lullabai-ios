//
//  AppDelegate.swift
//  LullabAI
//
//  Created by Keyur Hirani on 12/01/25.
//

import UIKit
import IQKeyboardManagerSwift
import AVFoundation
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set up AVAudioSession
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
//        let tabBarVC = Constants.StoryBoard.MAIN.instantiateViewController(withIdentifier: "RecordTempVC") as! RecordTempVC
//        window?.rootViewController = tabBarVC
//        window?.makeKeyAndVisible()
        
        if !UserDefaults.standard.bool(forKey: "isIntro") {
            UserDefaults.standard.set(true, forKey: "isIntro")
            UserDefaults.standard.synchronize()
            makeRootView(rootVC: rootView.Intro)
        }
        else if UserDefaults.standard.bool(forKey: "isLogin") {
            makeRootView(rootVC: rootView.Home)
        }
        else {
            makeRootView(rootVC: rootView.Login)
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      var handled: Bool

      handled = GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }

      // Handle other custom URL types.

      // If not handled by this app, return false.
      return false
    }

    func makeRootView(rootVC:rootView) {
        
        switch rootVC {
        case .Intro:
            let introVC = Constants.StoryBoard.MAIN.instantiateViewController(withIdentifier: "navIntro") as! UINavigationController
            window?.rootViewController = introVC
            window?.makeKeyAndVisible()
        case .Home:
            let tabBarVC = Constants.StoryBoard.HOME.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
            window?.rootViewController = tabBarVC
            window?.makeKeyAndVisible()
        case .Login:
            let loginVC = Constants.StoryBoard.MAIN.instantiateViewController(withIdentifier: "navLogin") as! UINavigationController
            window?.rootViewController = loginVC
            window?.makeKeyAndVisible()
        case .AddVoice:
            let addVoiceVC = Constants.StoryBoard.MAIN.instantiateViewController(withIdentifier: "navAddVoice") as! UINavigationController
            window?.rootViewController = addVoiceVC
            window?.makeKeyAndVisible()
        }
    }
}

enum rootView : String {
    case Intro
    case Login
    case Home
    case AddVoice
}
