//
//  AppDelegate.swift
//  spotifyAPI
//
//  Created by David Perez on 12/9/19.
//  Copyright © 2019 David Perez P. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    private let redirectUri = URL(string:"SpotifyIntegrationExample://callback")!
    private let clientIdentifier = "1a066ed9aa7645e898d9bb07a210e3fb"
    
    // keys
    static private let kAccessTokenKey = "access-token-key"
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: AppDelegate.kAccessTokenKey)
            defaults.synchronize()
        }
    }
    var window: UIWindow?
    
    lazy var appRemote: SPTAppRemote = {
        
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
}
