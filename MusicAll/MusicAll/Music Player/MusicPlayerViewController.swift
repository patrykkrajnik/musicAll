//
//  MusicPlayerViewController.swift
//  MusicAll
//
//  Created by Patryk Krajnik on 10/01/2021.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBOutlet weak var songArtworkView: UIImageView!
    
    @IBOutlet weak var playPauseButtonView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    private var timer: Timer!
    static var player: AVPlayer?
    
    var songTitle = "Song Title"
    var songArtist = "Artist"
    var isJsonOffline = false 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressSlider.addTarget(self, action: #selector(userSeek), for: UIControl.Event.valueChanged)
        
        setupInitialUI()
        playSongAt()
        setupAVAudioSession()
    }
    
    func setupInitialUI() {
        makeItRounded(view: playPauseButtonView, newSize: playPauseButtonView.frame.width)
        setupTitles()
        progressSlider.value = 0.0
        playButton.isHidden = true
        pauseButton.isHidden = false
    }
    
    func makeItRounded(view: UIView, newSize: CGFloat) {
        let saveCenter: CGPoint = view.center
        let newFrame: CGRect = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: newSize, height: newSize)
        
        view.frame = newFrame
        view.layer.cornerRadius = newSize / 2.0
        view.clipsToBounds = true
        view.center = saveCenter
    }
    
    func setupTitles() {
        if songTitle != "" {
            songTitleLabel.text = songTitle
        } else {
            songTitleLabel.isHidden = true
        }
        
        if songArtist != "" {
            artistNameLabel.text = songArtist
        } else {
            artistNameLabel.isHidden = true
        }
    }
    
    func updateButtons() {
        switch MusicPlayerViewController.isPlaying() {
        case true:
            playButton.isHidden = true
            pauseButton.isHidden = false
        default:
            playButton.isHidden = false
            pauseButton.isHidden = true
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        MusicPlayerViewController.player?.play()
        updateButtons()
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        MusicPlayerViewController.player?.pause()
        updateButtons()
    }
    
    func playSongAt() {
        var songURL = ""
        let playerItem: AVPlayerItem?
        
        if MusicPlayerViewController.player != nil {
            MusicPlayerViewController.player?.pause()
        }
        
        switch isJsonOffline {
        case true:
            songURL = Bundle.main.path(forResource: "\(songArtist) - \(songTitle)", ofType: "mp3")!
            playerItem = AVPlayerItem(url: URL(fileURLWithPath: songURL))
        default:
            songURL = "Here is a place for URL to your API with chosen song"
            let changedURL = songURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            playerItem = AVPlayerItem(url: URL(string: changedURL!)!)
        }
        
        MusicPlayerViewController.player = AVPlayer(playerItem: playerItem)
        MusicPlayerViewController.player?.volume = 1.0
        MusicPlayerViewController.player?.play()
        startTimer()
    }
    
    @objc func updateCurrentTime() {
        if (MusicPlayerViewController.player != nil) && !(MusicPlayerViewController.player?.currentItem?.duration.seconds.isNaN)! {
            progressSlider.maximumValue = Float((MusicPlayerViewController.player?.currentItem?.duration.seconds)!)
            progressSlider.value = Float((MusicPlayerViewController.player?.currentTime().seconds)!)
        }
        
        let currentDuration = Int(progressSlider.value)
        let minutes = currentDuration / 60
        let seconds = currentDuration % 60
        
        currentTimeLabel.text = NSString(format: "%i:%02i", minutes, seconds) as String
        updateTotalTime()
    }
    
    func updateTotalTime() {
        if progressSlider.maximumValue.isNaN {return}
        
        let totalDuration = Int(progressSlider.maximumValue)
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        
        totalTimeLabel.text = NSString(format: "%i:%02i", minutes, seconds) as String
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    @objc func userSeek() {
        let value = progressSlider.value
        if (MusicPlayerViewController.player != nil) && (MusicPlayerViewController.player?.currentTime() != nil) {
            MusicPlayerViewController.player?.seek(to: CMTime(seconds: Double(value), preferredTimescale: (MusicPlayerViewController.player?.currentTime().timescale)!))
        }
    }
    
    private func setupAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
            debugPrint("Playback OK")
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print(error)
        }
    }
    
    static func isPlaying() -> Bool {
        return (player != nil) && (player!.rate != 0) && (player!.error == nil)
    }
}
