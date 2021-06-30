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
import UBottomSheet

class KTCreateBookingConstants {
    
    // MARK: List of Constants
    
    static let DEFAULT_MAP_ZOOM : Float = 17.2
    static let PICKUP_MAP_ZOOM : Float = 17.2
    static let BOUNDS_MARKER_DISTANCE_THRESHOULD : Double = 2000
    static let DEFAULT_MAP_PADDING : Float = 0
    
}

class KTBaseCreateBookingController: KTBaseDrawerRootViewController {
    
    //MARK:- Public and private variables
    var fareBreakdown : KTFareViewController!
    public var pickupHint : String = ""
    public var callerId : String?
    public var promoCode : String = ""

    //MARK:- Outlets
    @IBOutlet weak var mapView : GMSMapView!
    @IBOutlet weak var carousel: ScalingCarouselView!
    @IBOutlet weak var btnPickupAddress: UIButton!
    @IBOutlet weak var btnDropoffAddress: SpringButton!
    @IBOutlet weak var btnRevealBtn : SpringButton!
    @IBOutlet weak var btnCancelBtn : SpringButton!
    @IBOutlet weak var btnRequestBooking :SpringButton!
    
    lazy var paymentSelectionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentSelectionBottomSheetController") as! PaymentSelectionBottomSheetController
    lazy var sheetCoordinator = UBottomSheetCoordinator(parent: self)
    
    lazy var backGroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
        layer.frame = view.bounds
        return layer
    }()
    
    var sheetPresented = false

    //MARK: - Map related variables
    var gmsMarker : Array<GMSMarker> = Array()
    var polyline = GMSPolyline()
    weak var animationPolyline = GMSPolyline()
    var path = GMSMutablePath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer: Timer!
    var bgPolylineColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
    
    //MARK:- REBook
    var booking : KTBooking?
    
    //MARK:- AllowScroll
    var allowScroll :Bool = true
}
