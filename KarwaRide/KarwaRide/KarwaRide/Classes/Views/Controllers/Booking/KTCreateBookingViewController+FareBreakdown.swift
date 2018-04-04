//
//  KTCreateBookingViewController+FareBreakdown.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

extension KTCreateBookingViewController {
    func hideFareBreakdown(animated : Bool) {
        
        if animated {
            UIView.animate(withDuration: 0.5,
                           delay: 0.1,
                           options: UIViewAnimationOptions.curveEaseIn,
                           animations: { () -> Void in
                            self.constraintFareToBox.constant = self.viewFareBreakdown.frame.size.height
                            self.viewFareBreakdown.alpha = 0.0
                            
                            self.view.layoutIfNeeded()
                            
            }, completion: { (finished) -> Void in
                self.viewFareBreakdown.isHidden = true
            })
        }
        else {
            
            constraintFareToBox.constant = viewFareBreakdown.frame.size.height
            viewFareBreakdown.alpha = 0.0
            self.viewFareBreakdown.isHidden = true
        }
    }
    
    func showFareBreakdown(animated : Bool,kvPair : [String: String],title:String ) {
        fareBreakdown.updateView(KeyValue: kvPair, title: title)
        fareBreakdown.delegate = self
        UIView.animate(withDuration: 0.5,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.viewFareBreakdown.isHidden = false
                        self.constraintFareToBox.constant = 0
                        
                        self.viewFareBreakdown.alpha = 1.0
                        self.view.layoutIfNeeded()
                        
        })
    }
    
    func updateFareBreakdown(kvPair : [String: String] ) {
        
        fareBreakdown.updateView(KeyValue: kvPair, title: "")
        fareBreakdown.delegate = self
        self.viewFareBreakdown.isHidden = false
        
    }
    
    func fareDetailVisible() -> Bool {
        
        return !viewFareBreakdown.isHidden
    }
    
    func btnBackTapped() {
        self.hideFareBreakdown(animated: true)
    }
    
    
    
}
