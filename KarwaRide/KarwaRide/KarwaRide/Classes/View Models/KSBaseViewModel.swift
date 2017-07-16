//
//  KSBaseViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

@objc protocol KSViewModelDelegate: NSObjectProtocol {
    @objc optional func modelDidStartLoading()
    
    @objc optional func modelDidLoad()
    
    @objc optional func modelFailedToLoadWithError(_ error: Error?)
}

class KSBaseViewModel: NSObject {
    
    /** The controller which is using this view model object, so that it can be notified in case of any events. */
    weak var delegate: KSViewModelDelegate?
    
    /**
     * Initializes a new view model object.
     *
     * @param delegate The controller which is using this view model object, so that it can be notified in case of any events.
     */
    init(del: Any) {
        super.init()
        delegate = del as? KSViewModelDelegate
        
    }
    
   
}
