//
//  KSBaseViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

@objc protocol KTViewModelDelegate: NSObjectProtocol {
    @objc optional func modelDidStartLoading()
    
    @objc optional func modelDidLoad()
    
    @objc optional func modelFailedToLoadWithError(_ error: Error?)
    
    @objc optional func showError(title:String, message:String)
    
    func userIntraction(enable: Bool)
    func showProgressHud(show : Bool)
    func showProgressHud(show : Bool, status:String)
    func hideProgressHud()
    func viewStoryboard() -> UIStoryboard
    
    @objc func dismiss()
}

class KTBaseViewModel: NSObject {
    
    /** The controller which is using this view model object, so that it can be notified in case of any events. */
    //weak var delegate: KTViewModelDelegate?
    weak var delegate : KTViewModelDelegate?
    
    /**
     * Initializes a new view model object.
     *
     * @param delegate The controller which is using this view model object, so that it can be notified in case of any events.
     */
    init(del: Any) {
        super.init()
        delegate = del as? KTViewModelDelegate
        
    }
    func viewDidLoad() {
    
    }
    
    func viewWillAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
}
