//
//  AppDelegate+Extension.swift
//  spotifyAPI
//
//  Created by David Perez on 12/18/19.
//  Copyright © 2019 David Perez P. All rights reserved.
//

import Foundation



extension AppDelegate: SPTAppRemoteDelegate{
    
    var playerViewController: ViewController {
        get {
            return window?.rootViewController as! ViewController
        }
    }
    
    class var sharedInstance: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let parameters = appRemote.authorizationParameters(from: url);

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
          print(errorDescription)
        }

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        playerViewController.appRemoteDisconnect()
        appRemote.disconnect()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.connect();
    }

    func connect() {
        playerViewController.appRemoteConnecting()
        appRemote.connect()
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        playerViewController.appRemoteConnected()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("didFailConnectionAttemptWithError")
        playerViewController.appRemoteDisconnect()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("didDisconnectWithError")
        playerViewController.appRemoteDisconnect()
    }

}
