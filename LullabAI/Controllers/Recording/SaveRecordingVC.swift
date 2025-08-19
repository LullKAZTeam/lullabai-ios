//
//  SaveRecordingVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 27/01/25.
//

import UIKit
import AVFoundation
import MediaPlayer

class SaveRecordingVC: UIViewController {
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var txtName: UITextField!
    
    var fileName = ""
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        setupAudioPlayer()
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
    
    @IBAction func onClickSaveVoice(_ sender: Any) {
        self.view.endEditing(true)
        
        if txtName.text! == "" {
            self.presentAlert(withTitle: "Oops!", message: "Please enter your voice name.")
        }
        else {
            
            saveRecording()
        }
    }
    
    @IBAction func onClickSaveAgain(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
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
}

extension SaveRecordingVC {
    
    func setupAudioPlayer() {
        // Load audio file
        let audioURL = getDocumentDirectory(fileName: fileName)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            
            // Set slider max value to the audio duration
            slider.maximumValue = Float(audioPlayer?.duration ?? 0)
            
            // Update total time label
            totalTimeLabel.text = formatTime(audioPlayer?.duration ?? 0)
            
            // Start the timer
            startTimer()
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }
    
    func startTimer() {
        
        slider.value = 0
        currentTimeLabel.text = "00:00"
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
}

extension SaveRecordingVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimer()
        btnPlay.isSelected = false
    }
}

extension SaveRecordingVC {
    
    func saveRecording() {
     
        do {
            
            let param: [String: Any] = [
                "name": txtName.text!
            ]
            
            let data = try Data.init(contentsOf: getDocumentDirectory(fileName: fileName))
            
            ApiHandler.shared.requestWithAudio(methodName: .createVoice, param: param, imageWithName: "voice", fileName: fileName, imageMIMEType: "audio/wav", image: data, vc: self, completion: { status, json, error in
                
                switch status {
                case .success:
                    _appDelegate.makeRootView(rootVC: .Home)
                case .processing:
                    break
                case .failed:
                    if let data = json?["data"] as? [String:Any], let error = data["error"] as? String {
                        self.presentAlert(withTitle: "Oops!", message: error)
                    }
                }
            })
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
