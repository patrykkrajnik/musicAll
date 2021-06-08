//
//  SongManager.swift
//  MusicAll
//
//  Created by Patryk Krajnik on 08/06/2021.
//

import Foundation
import AVFoundation
import MediaPlayer

struct Song {
    var songTitle: String
    var songArtist: String
    var songArtwork: String
    var isJsonOffline: Bool
}

class SongManager {
    
    var song: Song?
    
    static var player: AVPlayer?
    
    func appendMetadata(_ songTitle: String, _ songArtist: String, _ songArtwork: String, _ isJsonOffline: Bool) {
        song = Song(songTitle: songTitle, songArtist: songArtist, songArtwork: songArtwork, isJsonOffline: isJsonOffline)
    }
    
    func initSongPlaying() {
        var songURL = ""
        let playerItem: AVPlayerItem?
        
        if SongManager.player != nil {
            SongManager.player?.pause()
        }
        
        switch getJsonStatus() {
        case true:
            songURL = Bundle.main.path(forResource: "\(getSongArtist()) - \(getSongTitle())", ofType: "mp3")!
            playerItem = AVPlayerItem(url: URL(fileURLWithPath: songURL))
        default:
            songURL = "Here is a place for URL to your API with chosen song"
            let changedURL = songURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            playerItem = AVPlayerItem(url: URL(string: changedURL!)!)
        }
        
        SongManager.player = AVPlayer(playerItem: playerItem)
        SongManager.player?.volume = 1.0
        SongManager.player?.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        initSongPlaying()
    }
    
    func getSongTitle() -> String {
        return song?.songTitle ?? "Song Title"
    }
    
    func getSongArtist() -> String {
        return song?.songArtist ?? "Artist"
    }
    
    func getSongArtwork() -> String {
        return song?.songArtwork ?? "album_placeholder.png"
    }
    
    func getJsonStatus() -> Bool {
        return song?.isJsonOffline ?? true
    }
    
    static func isPlaying() -> Bool {
        return (player != nil) && (player?.rate != 0) && (player?.error == nil)
    }
}
