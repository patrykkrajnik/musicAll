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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialUI()
    }
    
    func setupInitialUI() {
        makeItRounded(view: playPauseButtonView, newSize: playPauseButtonView.frame.width)
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
    
    static func isPlaying() -> Bool {
        return (player != nil) && (player!.rate != 0) && (player!.error == nil)
    }
}
