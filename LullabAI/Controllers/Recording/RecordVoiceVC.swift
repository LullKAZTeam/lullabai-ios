//
//  RecordVoiceVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 22/01/25.
//

import UIKit
import AVFoundation

class RecordVoiceVC: UIViewController {

    @IBOutlet weak var lblRecordingStatus: UILabel!
    @IBOutlet weak var waveformView: WaveformView!
    @IBOutlet weak var textVoice: UITextView!
    
    var audioRecorder: AVAudioRecorder?
    var displayLink: CADisplayLink?
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAndRequestMicrophonePermission { success in
        }
        
        startWaveformUpdate()
        getRandomStory()
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickRecording(_ sender: Any) {
        
        if isRecording {
            stopRecording()
            displayLink?.invalidate()
            lblRecordingStatus.text = "Start Recording"
            
            if validateWAVFileDuration(fileName: "recording.wav") {
                let nextVC = Constants.StoryBoard.MAIN.instantiateViewController(identifier: "SaveRecordingVC") as! SaveRecordingVC
                nextVC.fileName = "recording.wav"
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            else {
                self.presentAlertWithCompletion(title: "Oops!", message: "Please record your voice for at least 10 seconds to ensure better quality.", options: ["OK"], optionStyle: [.default]) { action in
                    
                    self.waveformView.resetWaveform()
                }
            }
        } else {
            
            checkAndRequestMicrophonePermission { success in
                
                if success {
                    self.startRecording()
                    self.lblRecordingStatus.text = "Listinning....."
                }
                else {
                    self.showPermissionDeniedAlert()
                }
            }
        }
    }
    
    @IBAction func onClickRefresh(_ sender: Any) {
        
        if isRecording {
            self.presentAlert(withTitle: "Alert", message: "Please pause the recording before changing the story.")
        }
        else {
            self.waveformView.resetWaveform()
            getRandomStory()
        }
    }
    
    func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Microphone Access",
            message: "Microphone access is required to record audio. Please enable it in the Settings app.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingsURL) {
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    }
                }
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func validateWAVFileDuration(fileName: String) -> Bool {
        do {
            
            let audioFile = try AVAudioFile(forReading: getDocumentDirectory(fileName: fileName))
            let audioFormat = audioFile.processingFormat
            let sampleRate = audioFormat.sampleRate
            let frameCount = audioFile.length
            let durationInSeconds = Double(frameCount) / sampleRate

            return durationInSeconds >= 10.0
        } catch {
            print("Error reading audio file: \(error)")
            return false
        }
    }
}

extension RecordVoiceVC {
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                print("Microphone access denied")
            }
        }
    }
    
    func checkAndRequestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        let audioSession = AVAudioSession.sharedInstance()

        switch audioSession.recordPermission {
        case .undetermined:
            // Permission has not been requested yet
            audioSession.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("Microphone access granted")
                    } else {
                        print("Microphone access denied")
                    }
                    completion(granted)
                }
            }
        case .granted:
            // Permission already granted
            print("Microphone permission already granted")
            completion(true)
        case .denied:
            // Permission previously denied
            print("Microphone permission denied")
            completion(false)
        @unknown default:
            // Handle future cases
            print("Unknown microphone permission state")
            completion(false)
        }
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let settings: [String: Any] = [
                        AVFormatIDKey: Int(kAudioFormatLinearPCM), // Use Linear PCM for WAV
                        AVSampleRateKey: 44100.0,                 // Standard sample rate
                        AVNumberOfChannelsKey: 1,                 // Mono channel
                        AVLinearPCMBitDepthKey: 16,               // 16-bit audio
                        AVLinearPCMIsBigEndianKey: false,         // Little-endian format
                        AVLinearPCMIsFloatKey: false              // Integer audio
                    ]

//            let audioFilePath = NSTemporaryDirectory().appending("recording.m4a")
//            let audioURL = URL(fileURLWithPath: audioFilePath)
            
            let audioFilePath = getDocumentDirectory(fileName: "recording.wav")
            print(audioFilePath)
            audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()

            self.isRecording = true
            // Start updating waveform
            displayLink = CADisplayLink(target: self, selector: #selector(updateWaveform))
            displayLink?.add(to: .main, forMode: .default)
        } catch {
            print("  to set up recording: \(error)")
        }
    }
    
    func startWaveformUpdate() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            let power = recorder.averagePower(forChannel: 0)
            self.waveformView.addSample(value: power)
        }
    }
    @objc func updateWaveform() {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        waveformView.addSample(value: power)
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        print("Recording stopped")
    }
    
    func playRecording() {
        let audioFilename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("recording.m4a")

        let player = try? AVAudioPlayer(contentsOf: audioFilename)
        player?.play()
    }
}

extension RecordVoiceVC: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully")
        } else {
            print("Recording failed")
        }
    }
}

extension RecordVoiceVC {
    
    func getRandomStory() {
        
        _ = ApiHandler.shared.request(.get, for: .getRandomStory, param: nil, vc: self) { status, json, error in
            
            switch status {
            case .success:
                if let data = json?["data"] as? [String:Any], let story = data["story"] as? [String:Any] {
                    self.textVoice.text = story["story"] as? String
                }
                
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

// Waveform View
class WaveformView: UIView {
    private var samples: [CGFloat] = []
    private let maxSamples = 100

    func addSample(value: Float) {
        let normalizedValue = max(0, CGFloat(value + 100) / 160) // Normalize power to 0-1
        samples.append(normalizedValue)
        if samples.count > maxSamples {
            samples.removeFirst()
        }
        setNeedsDisplay()
    }

    func resetWaveform() {
        samples.removeAll() // Clear all samples
        setNeedsDisplay() // Redraw the view
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.clear(rect)
        context.setFillColor(UIColor.init("9D9FE6").cgColor)
        context.fill(rect)

        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2.0)

        let midY = rect.height / 2
        let sampleWidth = rect.width / CGFloat(maxSamples)
        
        for (i, sample) in samples.enumerated() {
            let x = CGFloat(i) * sampleWidth
            let y = midY - (sample * midY)
            let endY = midY + (sample * midY)
            
            context.move(to: CGPoint(x: x, y: y))
            context.addLine(to: CGPoint(x: x, y: endY))
        }
        
        context.strokePath()
    }
}
