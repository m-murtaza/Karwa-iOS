//
//  KTBaseCreateBookingController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import GoogleMaps
import ScalingCarousel
import Alamofire
import SwiftyJSON
import Spring

class KTCreateBookingConstants {
    
    // MARK: List of Constants
    
    static let DEFAULT_MAP_ZOOM : Float = 15.0
    static let PICKUP_MAP_ZOOM : Float = 17.0
    static let BOUNDS_MARKER_DISTANCE_THRESHOULD : Double = 2000
    static let DEFAULT_MAP_PADDING : Float = 100
    
}

class KTBaseCreateBookingController: KTBaseDrawerRootViewController,GMSMapViewDelegate {
    
    //MARK:- Public and private variables
    var fareBreakdown : KTFareViewController!
    public var pickupHint : String = ""
    public var callerId : String?
    
    //MARK:- Outlets
    @IBOutlet weak var mapView : GMSMapView!
    @IBOutlet weak var carousel: ScalingCarouselView!
    @IBOutlet weak var btnPickupAddress: UIButton!
    @IBOutlet weak var btnDropoffAddress: SpringButton!
    @IBOutlet weak var btnRevealBtn : UIButton!
    @IBOutlet weak var btnCancelBtn : UIButton!
    @IBOutlet weak var btnRequestBooking :SpringButton!
    @IBOutlet weak var imgPickDestBoxBG :UIImageView!
    @IBOutlet weak var btnPickDate: UIButton!
    @IBOutlet weak var btnCash :UIButton!
    @IBOutlet weak var viewFareBreakdown : UIView!
    
    
    //MARK: - Map related variables
    var gmsMarker : Array<GMSMarker> = Array()
    var polyline = GMSPolyline()
    weak var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer: Timer!
    var bgPolylineColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
    
    //MARK: - Constraints
    @IBOutlet weak var constraintBoxHeight : NSLayoutConstraint!
    @IBOutlet weak var constraintBoxBGImageHeight : NSLayoutConstraint!
    @IBOutlet weak var constraintBoxItemsTopSpace : NSLayoutConstraint!
    @IBOutlet weak var constraintBtnRequestBookingHeight : NSLayoutConstraint!
    @IBOutlet weak var constraintBoxBtnRequestBookingSpace : NSLayoutConstraint!
    @IBOutlet weak var constraintBtnRequestBookingBottomSpace : NSLayoutConstraint!
    //This is top align constraint for farebreakdown and box.
    @IBOutlet weak var constraintFareToBox : NSLayoutConstraint!
    
    //MARK:- REBook
    var booking : KTBooking?
    
    //MARK:- AllowScroll
    var allowScroll :Bool = true
}
