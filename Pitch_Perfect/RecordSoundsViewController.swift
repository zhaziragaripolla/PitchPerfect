//
//  RecordSoundsViewController.swift
//  Pitch_Perfect
//
//  Created by Zhazira Garipolla on 6/15/19.

//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {

    var audioRecorder : AVAudioRecorder?
    var timer : Timer?
    var isAudioRecordingGranted : Bool?
    let session = AVAudioSession.sharedInstance()
    
    @IBOutlet weak var showTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var stopRecordButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        askPermission()
        configureUI(false)
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
        guard isAudioRecordingGranted != nil else {
            return
        }
        setRecorder()
        configureUI(true)
        startRecorder()
    }
    
    //MARK: StopButton is pressed
    @IBAction func touchStopRecording(_ sender: Any) {
        stopRecorder()
        configureUI(false)
    }
    
    //MARK: Setting of appropriate UI
    private func configureUI(_ isRecording : Bool = false ) {
        statusLabel.text = isRecording ? "Recording in progress..." : "Tap to record"
        recordButton.isEnabled = !isRecording
        stopRecordButton.isEnabled = isRecording
        showTimeLabel.text = ""
    }
    
    //MARK: Getting path URL
    private func getURL()-> URL? {
        let dirpath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirpath, recordingName]
        guard let filepath = URL(string: pathArray.joined(separator: "/")) else {
            return nil
        }
        return filepath
    }
    
    // MARK: Prepare for recording an audio
    private func setRecorder() {
        guard let url = getURL() else {
            print("URL is nil")
            return
        }
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            audioRecorder = try AVAudioRecorder(url: url, settings: [:])
            audioRecorder?.delegate = self
        } catch {
            print ("Setting category to AVAudioSession is failed")
        }
    }
    
    // MARK: Start recording an audio
    private func startRecorder() {
        guard let audioRecorder = audioRecorder else {
            print("AVAudioRecorder instance is nil")
            return
        }
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,  selector: #selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
    }
    
    @objc private func updateAudioMeter(timer: Timer) {
        let min = Int(audioRecorder!.currentTime / 60)
        let sec = Int(audioRecorder!.currentTime.truncatingRemainder(dividingBy: 60))
        showTimeLabel.text = String(format: "%02d:%02d", min, sec)
        audioRecorder!.updateMeters()
    }
    
    // MARK: Stop recording an audio
    private func stopRecorder() {
        audioRecorder?.stop()
        timer?.invalidate()
        do {
            try session.setActive(false)
        } catch {
            print("Unable to activate Audio session")
        }
    }
    
    // MARK: Going to PlaySoundsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            print("Segue has no identifier")
            return
        }
        
        if identifier == "stopRecording" {
            let playSoundsVC = segue.destination as? PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC?.recordedAudioURL = recordedAudioURL
        } else {
            print("Did not recognize storyboard identifier")
        }
    }

}

extension RecordSoundsViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag else {
            print("Recording was not successfull")
            return
        }
        performSegue(withIdentifier: "stopRecording", sender: audioRecorder?.url)
    }
}




