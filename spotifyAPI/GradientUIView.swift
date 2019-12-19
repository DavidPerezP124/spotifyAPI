//
//  GradientUIView.swift
//  spotifyAPI
//
//  Created by David Perez on 12/10/19.
//  Copyright © 2019 David Perez P. All rights reserved.
//

import Foundation
@IBDesignable
class GradientUIImageView: UIImageView {
    override func layoutSubviews() {
        let view = UIView(frame: self.frame)

        let gradient = CAGradientLayer()

        gradient.frame = view.frame

        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]

        gradient.locations = [0.0, 1.0]

        view.layer.insertSublayer(gradient, at: 0)

        self.addSubview(view)

        self.bringSubviewToFront(view)
    }
}
