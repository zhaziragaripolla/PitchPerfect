//
//  RecordSoundsViewController.swift
//  Pitch_Perfect
//
//  Created by Zhazira Garipolla on 6/15/19.

//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    
    var audioRecorder : AVAudioRecorder!
    var filepath: URL!
    var timer : Timer!
    var isAudioRecordingGranted : Bool?
    let session = AVAudioSession.sharedInstance()
    
    
    @IBOutlet weak var showTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var stopRecordButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    enum RecordingState { case recording, notRecording }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        askPermission()
        congifureUI(.notRecording)
    }
    
    //MARK: Ask user a permission to record an audio
    private func askPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranted = true
            break
        case .denied:
            isAudioRecordingGranted = false
            break
        case .undetermined: AVAudioSession.sharedInstance().requestRecordPermission({ allowed in
            if allowed {
                self.isAudioRecordingGranted = true
            }
            else {
                self.isAudioRecordingGranted = false
            }
        })
            break
            
        default:
            break
            
        }
    }
    
    //MARK: RecordButton is pressed
    
    @IBAction func touchStartRecording(_ sender: Any) {
        guard isAudioRecordingGranted! else {
            return
        }
        setRecorder()
        congifureUI(.recording)
        startRecorder()
    }
    
    //MARK: StopButton is pressed
    @IBAction func touchStopRecording(_ sender: Any) {
        stopRecorder()
        congifureUI(.notRecording)
    }
    
    //MARK: Setting of appropriate UI
    private func congifureUI(_ recordingState : RecordingState ) {
        switch(recordingState) {
        case .recording:
            recordButton.isEnabled = false
            stopRecordButton.isEnabled = true
            statusLabel.text = "Recording in progress..."
        case .notRecording:
            statusLabel.text = "Tap to start recording"
            recordButton.isEnabled = true
            stopRecordButton.isEnabled = false
            showTimeLabel.text = ""
        }
    
    }
    
    // Mark: Prepare for recording an audio
    private func setRecorder() {
        let dirpath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirpath, recordingName]
        filepath = URL(string: pathArray.joined(separator: "/"))
        print(filepath!.description)
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            audioRecorder = try AVAudioRecorder(url: filepath, settings: [:])
            audioRecorder.delegate = self
            
        } catch {
            print ("Setting category to AVAudioSession is failed")
        }
    }
    
    // MARK: Start recording an audio
    private func startRecorder() {
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,  selector: #selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
    }
    
    @objc private func updateAudioMeter(timer: Timer) {
        let min = Int(audioRecorder.currentTime / 60)
        let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
        let totalTimeString = String(format: "%02d:%02d", min, sec)
        showTimeLabel.text = totalTimeString
        audioRecorder.updateMeters()
    }
    
    // MARK: Stop recording an audio
    private func stopRecorder() {
        audioRecorder.stop()
        timer.invalidate()
        try! session.setActive(false)
    }
    
    // MARK: Going to PlaySoundsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as? PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC?.recordedAudioURL = recordedAudioURL
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successfull")
        }
        
    }
    
    
}




