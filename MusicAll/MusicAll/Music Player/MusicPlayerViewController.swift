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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
