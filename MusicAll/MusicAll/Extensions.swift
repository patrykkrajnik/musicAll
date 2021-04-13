//
//  Extensions.swift
//  MusicAll
//
//  Created by Patryk Krajnik on 30/03/2021.
//

import Foundation
import UIKit
import MediaPlayer

extension UIViewController {
    func updateCommandCenterInfo(songName: String, songArtist: String, imageName: String) {
        var nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = songName
        nowPlayingInfo[MPMediaItemPropertyArtist] = songArtist
        
        if let image = UIImage(named: imageName) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        print(nowPlayingInfo)
    }
}

extension UIView {
    func constraintWith(identifier: String) -> NSLayoutConstraint? {
        return self.constraints.first(where: {$0.identifier == identifier})
    }
}

extension UIDevice {
    var hasNotch: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        if UIDevice.current.orientation.isPortrait {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
}
