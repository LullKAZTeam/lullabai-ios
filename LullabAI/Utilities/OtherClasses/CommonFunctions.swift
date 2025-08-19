//
//  CommonFunctions.swift
//  LullabAI
//
//  Created by Keyur Hirani on 27/01/25.
//

import Foundation

func getDocumentDirectory(fileName:String) -> URL {
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let audioFilePath = documentDirectory.appendingPathComponent(fileName)
    return audioFilePath
}
