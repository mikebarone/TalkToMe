//
//  ViewController.swift
//  TalkToMe
//
//  Created by Mike Barone on 2017-03-15.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var trascriptionTextField: UITextView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var buttonPlay: CircleButton!
    
    var audioRecorder:AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording: Bool = false
    
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                          AVNumberOfChannelsKey : NSNumber(value: Int32(1)),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.high.rawValue))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: directoryURL()!, settings: recordSettings)
            audioRecorder.prepareToRecord()
        } catch {}
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        activitySpinner.stopAnimating()
        activitySpinner.isHidden = true
    }

    @IBAction func playButtonPressed(_ sender: Any) {
        if isRecording {
            isRecording = false
            buttonLabel.text = "Speak"
            buttonPlay.cornerRadius = 30
            buttonPlay.backgroundColor = UIColor.init(red: 170/255, green: 0, blue: 0, alpha: 1)
            
            audioRecorder.stop()
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(false)
                do {
                    try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                    let sound = try AVAudioPlayer(contentsOf: audioRecorder.url)
                    self.audioPlayer = sound
                    self.audioPlayer.delegate = self
                    sound.play()
                    activitySpinner.isHidden = false
                    activitySpinner.startAnimating()
                } catch {
                    print("error")
                }
                let recognizer = SFSpeechRecognizer()
                let request = SFSpeechURLRecognitionRequest(url: audioRecorder.url)
                recognizer?.recognitionTask(with: request) { (result, error) in
                    if let error = error {
                        print("There was an error: \(error)")
                    } else {
                        self.trascriptionTextField.text = result?.bestTranscription.formattedString
                    }
                }
                
            } catch {}
        } else {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                isRecording = true
                buttonLabel.text = "Stop"
                buttonPlay.cornerRadius = 15
                buttonPlay.backgroundColor = UIColor.init(red: 0, green: 170/255, blue: 0, alpha: 1)
                requestSpeechAuth()
            } catch {}

        }

    }
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("TalkToMe.m4a")
        return soundURL
    }
    
    func startRecording(){
        if !audioRecorder.isRecording {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
            } catch {}
        }
    }
    
    func requestSpeechAuth(){
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                self.startRecording()
            }
        }
    }
}

