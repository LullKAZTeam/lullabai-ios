//
//  PlayerVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 03/02/25.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlayerVC: UIViewController {
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var sliderVolume: UISlider!
    @IBOutlet weak var imgViewStory: UIImageView!
    @IBOutlet weak var lblStoryName: UILabel!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblTitleHeader: UILabel!
    @IBOutlet weak var btnBookMark: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    
    var currentIndex = 0
    var audioURL = ""
    var arrayAudioData = [[String:Any]]()
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupURL()
    }
    
    func setupURL() {
        
        var userId = ""
        if let userData = UserDefaults.standard.object(forKey: "userInfo") as? [String:Any] {
            userId = "\(userData["id"] ?? "")"
        }
        
        if let url = arrayAudioData[currentIndex]["ai_voice"] as? String, url != "" {
            audioURL = url
            downloadAudioFile()
            if let story = arrayAudioData[currentIndex]["story"] as? [String:Any] {
                imgViewStory.kf.setImage(with: URL(string: story["image"] as! String), placeholder: nil)
                lblStoryName.text = story["title"] as? String
                lblTitleHeader.text = story["title"] as? String
            }
            lblCategoryName.text = arrayAudioData[currentIndex]["category"] as? String
            
            if "\(arrayAudioData[currentIndex]["is_collection"] ?? "0")" == "1" {
                btnBookMark.isSelected = true
            }
            else {
                btnBookMark.isSelected = false
            }
            
            if let downloadData = UserDefaults.standard.object(forKey: "DownloadStory") as? [[String:Any]] {
                if downloadData.filter({("\($0["id"] ?? "")" == "\(arrayAudioData[currentIndex]["id"] ?? "")") && ("\($0["user_id"] ?? "")" == userId)}).count > 0 {
                    btnDownload.isSelected = true
                }
                else {
                    btnDownload.isSelected = false
                }
            }
        }
    }
    
    func downloadAudioFile() {
        
        downloadAudio(from: audioURL) { url in
            DispatchQueue.main.async {
                self.setupAudioPlayer()
                self.setupVolumeSlider()
            }
        }
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.view.endEditing(true)
        
        if let audioPlayer = audioPlayer {
            
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                stopTimer()
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        
        if currentIndex < arrayAudioData.count - 1 {
            
            btnPlay.isSelected = false
            slider.value = 0
            currentTimeLabel.text = "00:00"
            
            if ((audioPlayer?.isPlaying) != nil) {
                audioPlayer?.pause()
                stopTimer()
            }
            
            currentIndex += 1
            setupURL()
        }
    }
    
    @IBAction func onClickPrevious(_ sender: Any) {
        
        if currentIndex > 0 {
            
            btnPlay.isSelected = false
            slider.value = 0
            currentTimeLabel.text = "00:00"

            if ((audioPlayer?.isPlaying) != nil) {
                audioPlayer?.pause()
                stopTimer()
            }
            
            currentIndex -= 1
            setupURL()
        }
    }
    
    @IBAction func onClickPlay(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if btnPlay.isSelected {
            btnPlay.isSelected = false
            guard let audioPlayer = audioPlayer else { return }

            if audioPlayer.isPlaying {
                audioPlayer.pause()
                stopTimer()
            }
        }
        else {
            btnPlay.isSelected = true
            guard let audioPlayer = audioPlayer else { return }

            if !audioPlayer.isPlaying {
                audioPlayer.play()
                startTimer()
            }
        }
    }
    
    @IBAction func onClickSlider(_ sender: UISlider) {
        self.view.endEditing(true)
        
        guard let audioPlayer = audioPlayer else { return }
        
        audioPlayer.currentTime = TimeInterval(sender.value)
        currentTimeLabel.text = formatTime(audioPlayer.currentTime)
    }
    
    @IBAction func onClickVoulmeSlider(_ sender: UISlider) {
        self.view.endEditing(true)
        audioPlayer?.volume = sender.value
    }
    
    @IBAction func onClickBookmark(_ sender: Any) {
        bookmark()
    }
    
    @IBAction func onClickDownload(_ sender: Any) {
        
        var userId = ""
        if let userData = UserDefaults.standard.object(forKey: "userInfo") as? [String:Any] {
            userId = "\(userData["id"] ?? "")"
        }
        
        if btnDownload.isSelected == false {
            var audioData = arrayAudioData[currentIndex]
            audioData["user_id"] = userId
            
            if let downloadData = UserDefaults.standard.object(forKey: "DownloadStory") as? [[String:Any]] {
                
                var data:[[String:Any]] = downloadData
                data.append(audioData)
                UserDefaults.standard.set(data, forKey: "DownloadStory")
                UserDefaults.standard.synchronize()
            }
            else {
                UserDefaults.standard.set([audioData], forKey: "DownloadStory")
                UserDefaults.standard.synchronize()
            }
            btnDownload.isSelected = true
        }
        else {
            if let downloadData = UserDefaults.standard.object(forKey: "DownloadStory") as? [[String:Any]] {
                
                var data:[[String:Any]] = downloadData
                data.removeAll(where: {("\($0["id"] ?? "")" == "\(arrayAudioData[currentIndex]["id"] ?? "")") && ("\($0["user_id"] ?? "")" == userId)})
                UserDefaults.standard.set(data, forKey: "DownloadStory")
                UserDefaults.standard.synchronize()
            }
            
            btnDownload.isSelected = false
        }
    }
}

extension PlayerVC {
    
    func setupVolumeSlider() {
                        
        sliderVolume.minimumValue = 0.0 // Min volume
        sliderVolume.maximumValue = 1.0 // Max volume
        sliderVolume.value = audioPlayer?.volume ?? 0 // Default value
    }
}

extension PlayerVC {
    
    func setupAudioPlayer() {
        // Load audio file
        guard let url = URL(string: audioURL) else {
            print("Invalid URL")
            return
        }
        
        let audioURL = getDocumentDirectory(fileName: url.lastPathComponent)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            onClickPlay(UIButton())
            
            slider.maximumValue = Float(audioPlayer?.duration ?? 0)
            totalTimeLabel.text = formatTime(audioPlayer?.duration ?? 0)
            
            startTimer()
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }
    
    func startTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateSlider() {
        guard let audioPlayer = audioPlayer else { return }
        
        slider.value = Float(audioPlayer.currentTime)
        currentTimeLabel.text = formatTime(audioPlayer.currentTime)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func downloadAudio(from urlString: String, completion: @escaping (URL?) -> Void) {
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        let fileURL = getDocumentDirectory(fileName: url.lastPathComponent)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            completion(fileURL)
            return
        }
        
        // Create a URLSession download task
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error = error {
                print("Download failed: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let tempURL = tempURL else {
                print("No file URL returned")
                completion(nil)
                return
            }
            
            do {
                // Get the document directory
                let fileURL = getDocumentDirectory(fileName: url.lastPathComponent)
                
                // Remove the file if it already exists
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                
                // Move the file to the document directory
                try FileManager.default.moveItem(at: tempURL, to: fileURL)
                print("File saved at: \(fileURL.path)")
                
                completion(fileURL)
            } catch {
                print("File save error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        // Start the download task
        task.resume()
    }
}

extension PlayerVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimer()
        btnPlay.isSelected = false
        slider.value = 0
        currentTimeLabel.text = "00:00"
        onClickNext(UIButton())
    }
}

extension PlayerVC {
    
    func bookmark() {
        
        let param = ["history": "\(arrayAudioData[currentIndex]["id"] ?? "")", "flag": btnBookMark.isSelected ? "0" : "1"] as [String : Any]
        
        _ = ApiHandler.shared.request(for: .bookmarkStory, param: param.keys.count > 0 ? param : nil, vc: self) { status, json, error in
            
            switch status {
            case .success:
                self.btnBookMark.isSelected = !self.btnBookMark.isSelected
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
