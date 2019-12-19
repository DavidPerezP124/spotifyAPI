//
//  ViewController.swift
//  spotifyAPI
//
//  Created by David Perez on 12/9/19.
//  Copyright © 2019 David Perez P. All rights reserved.
//

import UIKit


class ViewController: UIViewController, SpotifyRequirements{
    
    
    @IBOutlet weak var playPauseButton: RoundedButton!
    
    
    @IBOutlet weak var trackProgress: UIProgressView!
    
    
    @IBOutlet weak var duration: UILabel!
    
    let playURI = "spotify:album:5uMfshtC2Jwqui0NUyUYIL"
    let trackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"
    var playerState: SPTAppRemotePlayerState?
    var subscribedToPlayerState: Bool = false
    
    @IBOutlet weak var trackNameLabel: UILabel!
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var prevButton: UIButton!
    
    @IBAction func didPressNextButton(_ sender: AnyObject) {
        skipNext()
    }
    
    
    @IBOutlet weak var albumArtImageView: GradientUIImageView!
    
    
    
    @IBAction func didPressPlayPauseButton(_ sender: AnyObject) {
        if !(appRemote.isConnected) {
            if (!appRemote.authorizeAndPlayURI(playURI)) {
            }
        } else if playerState == nil || playerState!.isPaused {
            startPlayback()
        } else {
            pausePlayback()
        }
    }
    
    var appRemote: SPTAppRemote {
        get {
            return AppDelegate.sharedInstance.appRemote
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playPauseButton.setImage(UIImage(named: "Triangle"), for: UIControl.State.highlighted)
    }
}

