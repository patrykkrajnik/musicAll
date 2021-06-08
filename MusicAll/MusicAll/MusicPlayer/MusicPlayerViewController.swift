//
//  MusicPlayerViewController.swift
//  MusicAll
//
//  Created by Patryk Krajnik on 10/01/2021.
//

import UIKit
import AVFoundation
import MediaPlayer

class MusicPlayerViewController: UIViewController {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLeftLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBOutlet weak var songArtworkView: UIImageView!
    
    @IBOutlet weak var playPauseButtonView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    var songManager: SongManager?
    private var timer: Timer!
    
    var songTitle = ""
    var songArtist = ""
    var songArtwork = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressSlider.addTarget(self, action: #selector(userSeek), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startSongPlaying()
        setupAVAudioSession()
        setupInitialUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let safeSongManager = songManager {
            updateCommandCenterInfo(songName: safeSongManager.getSongTitle(),
                                    songArtist: safeSongManager.getSongArtist(),
                                    songArtwork: safeSongManager.getSongArtwork())
        }
    }
    
    func setupInitialUI() {
        makeItRounded(view: playPauseButtonView, newSize: playPauseButtonView.frame.width)
        progressSlider.value = 0.0
        updateButtons()
        setupTitles()
        setupArtwork()
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
        if let safeSongTitle = songManager?.getSongTitle() {
            songTitleLabel.text = safeSongTitle
        } else if songTitle != "" {
            songTitleLabel.text = songTitle
        } else {
            songTitleLabel.isHidden = true
        }
        
        if let safeSongArtist = songManager?.getSongArtist() {
            songArtistLabel.text = safeSongArtist
        } else if songArtist != "" {
            songArtistLabel.text = songArtist
        } else {
            songArtistLabel.isHidden = true
        }
    }
    
    func setupArtwork() {
        if let safeSongArtwork = songManager?.getSongArtwork() {
            songArtworkView.image = UIImage(named: safeSongArtwork)
        } else if songArtwork != "" {
            songArtworkView.image = UIImage(named: songArtwork)
        } else {
            songArtworkView.image = UIImage(named: "album_placeholder.png")
        }
    }
    
    func updateButtons() {
        switch SongManager.isPlaying() {
        case true:
            playButton.isHidden = true
            pauseButton.isHidden = false
        default:
            playButton.isHidden = false
            pauseButton.isHidden = true
        }
    }
    
    func pauseSong() {
        SongManager.player?.pause()
        updateButtons()
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                self.songArtworkView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            },
            completion: nil)
    }
    
    func playSong() {
        SongManager.player?.play()
        updateButtons()
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: .curveEaseIn,
            animations: {
                self.songArtworkView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            },
            completion: nil)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        playSong()
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        pauseSong()
    }
    
    func startSongPlaying() {
        songManager?.initSongPlaying()
        startTimer()
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        startSongPlaying()
    }
    
    @objc func setupTimers() {
        if (SongManager.player != nil) && !(SongManager.player?.currentItem?.duration.seconds.isNaN)! {
            progressSlider.maximumValue = Float((SongManager.player?.currentItem?.duration.seconds)!)
            progressSlider.value = Float((SongManager.player?.currentTime().seconds)!)
        }
        
        setupCurrentTime()
        
        if progressSlider.value > 0.0 {
            activityIndicator.isHidden = true
        }
    }
    
    func setupCurrentTime() {
        if progressSlider.value.isNaN {return}
        
        let currentDuration = Int(progressSlider.value)
        let minutes = currentDuration / 60
        let seconds = currentDuration % 60
        
        currentTimeLabel.text = NSString(format: "%i:%02i", minutes, seconds) as String
        setupCurrentTimeLeft(currentDuration: currentDuration)
    }
    
    func setupCurrentTimeLeft(currentDuration: Int) {
        if progressSlider.maximumValue.isNaN {return}
        
        let totalDuration = Int(progressSlider.maximumValue)
        let currentDurationLeft = totalDuration - currentDuration
        let minutes = currentDurationLeft / 60
        let seconds = currentDurationLeft % 60
        
        currentTimeLeftLabel.text = NSString(format: "-%i:%02i", minutes, seconds) as String
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setupTimers), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    @objc func userSeek() {
        let value = progressSlider.value
        if (SongManager.player != nil) && (SongManager.player?.currentTime() != nil) {
            SongManager.player?.seek(to: CMTime(seconds: Double(value), preferredTimescale: (SongManager.player?.currentTime().timescale)!))
        }
    }
    
    private func setupAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            debugPrint("Playback OK")
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
            setupCommandCenterRemoteControl()
        } catch {
            print(error)
        }
    }
    
    func setupCommandCenterRemoteControl() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.nextTrackCommand.isEnabled = false
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            playSong()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            pauseSong()
            return .success
        }
    }
}
