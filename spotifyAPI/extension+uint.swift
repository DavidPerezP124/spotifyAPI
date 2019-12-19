//
//  extension+uint.swift
//  spotifyAPI
//
//  Created by David Perez on 12/10/19.
//  Copyright © 2019 David Perez P. All rights reserved.
//

import Foundation

extension UInt {
    var msToSeconds: UInt {
        return self / 1000
    }
    var secondsToMinutesSeconds: (Int, Int) {
        return (Int((self % 3600) / 60), Int((self % 3600) % 60))
    }
}
