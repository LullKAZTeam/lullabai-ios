//
//  RecordTempVC.swift
//  LullabAI
//
//  Created by Keyur Hirani on 23/01/25.
//

import UIKit
import AVFoundation

class RecordTempVC: UIViewController, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    var displayLink: CADisplayLink?
    var frameCounter = 0
    
    @IBOutlet weak var waveformView: WaveformView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Add waveform view

        // Add record button
        let recordButton = UIButton(frame: CGRect(x: (view.frame.width - 100) / 2, y: 350, width: 100, height: 50))
        recordButton.setTitle("Record", for: .normal)
        recordButton.backgroundColor = .systemBlue
        recordButton.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        view.addSubview(recordButton)
        
        startWaveformUpdate()
    }

    @objc func toggleRecording() {
        if let recorder = audioRecorder, recorder.isRecording {
            // Stop recording
            stopRecording()
            displayLink?.invalidate()
        } else {
            // Start recording
            startRecording()
        }
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let audioFilePath = NSTemporaryDirectory().appending("recording.m4a")
            let audioURL = URL(fileURLWithPath: audioFilePath)

            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()

            // Start updating waveform
            displayLink = CADisplayLink(target: self, selector: #selector(updateWaveform))
            displayLink?.add(to: .main, forMode: .default)
        } catch {
            print("Failed to set up recording: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        print("Recording stopped")
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
}

