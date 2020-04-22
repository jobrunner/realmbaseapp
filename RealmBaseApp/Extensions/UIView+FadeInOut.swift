//
//  UIView+FadeInOut.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 13.05.19.
//  Copyright © 2019 Mayflower GmbH. All rights reserved.
//

import UIKit

extension UIView {
    func fadeIn(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }

    func fadeOut(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
}
