//
//  VoiceHandler.swift
//  LullabAI
//
//  Created by Keyur Hirani on 31/01/25.
//

import Foundation

class VoiceHandler: NSObject {
 
    static let shared = VoiceHandler()
    
    var arrayVoices = [[String:Any]]()
    
    func getVoice(complition:@escaping(Bool) -> ()) {
        
        _ = ApiHandler.shared.request(.get, for: .getVoice, param: nil, vc: nil) { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any], let voice = data["voices"] as? [[String:Any]] {
                    self.arrayVoices = voice
                    complition(true)
                }
                else {
                    complition(false)
                }
            case .processing:
                complition(false)
            case .failed:
                complition(false)
            }
        }
    }
}
