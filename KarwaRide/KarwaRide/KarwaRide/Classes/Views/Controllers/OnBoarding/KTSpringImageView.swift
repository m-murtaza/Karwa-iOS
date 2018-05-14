//
//  KTSpringImageView.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/10/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring

class KTSpringImageView: SpringImageView {

    private var initialAnimation : String = ""
    private var initialDuration : CGFloat = 0.0
    private var initialDelay : CGFloat = 0.0
    private var initialScaleX : CGFloat = 0.0
    private var initialScaleY : CGFloat = 0.0
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override open func awakeFromNib() {
        super.awakeFromNib()
        initialAnimation = animation
        initialDuration = duration
        initialDelay = delay
        initialScaleX = scaleX
        initialScaleY = scaleY
    }
    
    open func ktAnimate() {
        animation = initialAnimation
        duration = initialDuration
        delay = initialDelay
        scaleX = initialScaleX
        scaleY = initialScaleY
        animate()
    }
    
    public func ktAnimateNext(completion: @escaping () -> ()) {
        animation = initialAnimation
        duration = initialDuration
        delay = initialDelay
        scaleX = initialScaleX
        scaleY = initialScaleY
        animate()
        animateNext(completion: completion)
        
    }
}
