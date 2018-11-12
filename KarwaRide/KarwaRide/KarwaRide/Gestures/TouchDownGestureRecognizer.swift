//
//  TouchDownGestureRecognizer.swift
//  KarwaRide
//
//  Created by Sam Ash on 11/12/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TouchDownGestureRecognizer: UIGestureRecognizer
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent)
    {
        if self.state == .possible {
            self.state = .recognized
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent)
    {
        self.state = .failed
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent)
    {
        if self.state == .possible {
            self.state = .recognized
        }
    }
}
