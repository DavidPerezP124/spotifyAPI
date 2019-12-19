//
//  MusicControllerView.swift
//  spotifyAPI
//
//  Created by David Perez on 12/9/19.
//  Copyright © 2019 David Perez P. All rights reserved.
//

import UIKit


@IBDesignable // Usable in Storyboard
class RoundedButton: UIButton{
       override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.width/2
    }
}
