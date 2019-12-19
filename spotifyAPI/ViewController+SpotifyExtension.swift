//
//  ViewController+SpotifyExtension.swift
//  spotifyAPI
//
//  Created by David Perez on 12/18/19.
//  Copyright © 2019 David Perez P. All rights reserved.
//

import Foundation

@objc
protocol SpotifyRequirements {
    var playURI : String {get}
    /**
        Set to false
     */
    var subscribedToPlayerState: Bool {get set}
    var trackIdentifier: String {get}
    /**
    add @IBOutlet to this
    */
    var duration: UILabel! {get set}
    /**
    add @IBOutlet to this
    */
    var playerState: SPTAppRemotePlayerState? {get set}
    var playPauseButton: RoundedButton! {get set}
    /**
     The appRemote is the link between the application and the spotify app, acting as a proxy for the actual app
     
     It's value when read should be the appRemote from the AppDelegate shared instance:
     
     ```
     get {
         return AppDelegate.sharedInstance.appRemote
     }
     ```
     */
    var appRemote: SPTAppRemote {get}
    /**
    add @IBOutlet to this
    */
    var trackNameLabel : UILabel! {get set}
    /**
    add @IBOutlet to this
    */
    var nextButton: UIButton! {get set}
    /**
     add @IBOutlet to this
     */
    var albumArtImageView: GradientUIImageView! {get set}
    func didPressNextButton(_ sender: AnyObject)
}


extension ViewController:  SPTAppRemotePlayerStateDelegate,
   SPTAppRemoteUserAPIDelegate {
    
    
    
    private func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        updatePlayPauseButtonState(playerState.isPaused)
        
        trackNameLabel.text = playerState.track.name + "\n" + playerState.track.artist.name
        fetchAlbumArtForTrack(playerState.track) { (image) -> Void in
            self.updateAlbumArtWithImage(image)
        }
        fetchProgressForTrack(playerState.track) { (duration) in
            let toTime = duration?.msToSeconds.secondsToMinutesSeconds
            self.duration.text = " \(toTime!.0) min \(toTime!.1) sec"
        }
        updateViewWithRestrictions(playerState.playbackRestrictions)
    }
    
    private func updateViewWithRestrictions(_ restrictions: SPTAppRemotePlaybackRestrictions) {
        nextButton.isEnabled = restrictions.canSkipNext
    }
    
    private func encodeStringAsUrlParameter(_ value: String) -> String {
        let escapedString = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return escapedString!
    }
    
    private func enableInterface(_ enabled: Bool = true) {
        if (!enabled) {
            albumArtImageView.image = nil
            updatePlayPauseButtonState(true);
        }
    }
    
    
    
    private func updatePlayPauseButtonState(_ paused: Bool) {
        let playPauseButtonImage = paused ? UIImage(named: "play") : UIImage(named: "pause")
        playPauseButton.setImage(playPauseButtonImage, for: UIControl.State())
        playPauseButton.setImage(playPauseButtonImage, for: .highlighted)
    }
    
    func skipNext() {
        appRemote.playerAPI?.skip(toNext: defaultCallback)
    }
    
    private func skipPrevious() {
        appRemote.playerAPI?.skip(toPrevious: defaultCallback)
    }
    /**
     Use this function once the appRemote is connected.
    
     first check the appRemote.isConnected state if false, authorize the app and play if the playerState is nil or paused:
        
        ```
        if !(appRemote.isConnected) {
                if (!appRemote.authorizeAndPlayURI(playURI)) {
                }
            } else if playerState == nil || playerState!.isPaused {
                startPlayback()
            } else {
                pausePlayback()
            }
        ```
     */
    func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
    }
    
    func pausePlayback() {
        appRemote.playerAPI?.pause(defaultCallback)
    }
    
    private func playTrack() {
        appRemote.playerAPI?.play(trackIdentifier, callback: defaultCallback)
    }
    
    private func enqueueTrack() {
        appRemote.playerAPI?.enqueueTrackUri(trackIdentifier, callback: defaultCallback)
    }
    
    private func toggleShuffle() {
        guard let playerState = playerState else { return }
        appRemote.playerAPI?.setShuffle(!playerState.playbackOptions.isShuffling, callback: defaultCallback)
    }
    
    private func getPlayerState() {
        appRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            
            let playerState = result as! SPTAppRemotePlayerState
            self.updateViewWithPlayerState(playerState)
        }
    }
    
    
    
    private func playTrackWithIdentifier(_ identifier: String) {
        appRemote.playerAPI?.play(identifier, callback: defaultCallback)
    }
    
    private func subscribeToPlayerState() {
        guard (!subscribedToPlayerState) else { return }
        appRemote.playerAPI!.delegate = self
        appRemote.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
        }
    }
    
    private func unsubscribeFromPlayerState() {
        guard (subscribedToPlayerState) else { return }
        appRemote.playerAPI?.unsubscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = false
        }
    }
    
    private func toggleRepeatMode() {
        guard let playerState = playerState else { return }
        let repeatMode: SPTAppRemotePlaybackOptionsRepeatMode = {
            switch playerState.playbackOptions.repeatMode {
            case .off: return .track
            case .track: return .context
            case .context: return .off
            default: return .off
            }
        }()
        
        appRemote.playerAPI?.setRepeatMode(repeatMode, callback: defaultCallback)
    }
    
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                }
            }
        }
    }
    
    private func updateAlbumArtWithImage(_ image: UIImage) {
        self.albumArtImageView.image = image
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        self.albumArtImageView.layer.add(transition, forKey: "transition")
    }
    
    
    
    private func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        appRemote.imageAPI?.fetchImage(forItem: track, with:CGSize(width: 1000, height: 1000), callback: { (image, error) -> Void in
            guard error == nil else { return }
            
            let image = image as! UIImage
            callback(image)
        })
    }
    
    
    private func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Get Track Progress
    
    private func fetchProgressForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UInt?) -> Void) {
        callback(track.duration)
    }
    
    
    
    // MARK: - <SPTAppRemotePlayerStateDelegate>
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
        updateViewWithPlayerState(playerState)
    }
    
    // MARK: - <SPTAppRemoteUserAPIDelegate>
    
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
    }
    
    func showError(_ errorDescription: String) {
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func appRemoteConnecting() {
    }
    
    func appRemoteConnected() {
        subscribeToPlayerState()
        getPlayerState()
        enableInterface(true)
    }
    
    func appRemoteDisconnect() {
        //  connectionIndicatorView.state = .disconnected
        self.subscribedToPlayerState = false
        enableInterface(false)
    }
    
}
