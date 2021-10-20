//
//  VehicleDetailBottomSheetVC.swift
//  KarwaRide
//
//  Created by Piecyfer on 18/10/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation
import UBottomSheet
import Spring
import ABLoaderView
import FittedSheets
import UIKit
import Spring

class VehicleDetailBottomSheetVC: KTBaseViewController, Draggable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var lblHeader: LocalisableSpringLabel!
    @IBOutlet weak var lblDescription: SpringLabel!
    @IBOutlet weak var lblVehicleName: SpringLabel!
    @IBOutlet weak var lblVehicleFare: SpringLabel!
    @IBOutlet weak var lblCapacity: SpringLabel!
    @IBOutlet weak var lblTime: SpringLabel!
    @IBOutlet weak var lblStartingFare: SpringLabel!
    @IBOutlet weak var lblMinFare: SpringLabel!
    @IBOutlet weak var lblKmFare: SpringLabel!
    @IBOutlet weak var lblPromo: SpringLabel!
    @IBOutlet weak var lblTotal: SpringLabel!
    @IBOutlet weak var btnRequestBooking: SpringButton!
    
    @IBOutlet weak var heightOFScrollViewContent: NSLayoutConstraint!
    
    var vModel: KTCreateBookingViewModel?
    var sheet: SheetViewController?
    var sheetCoordinator: UBottomSheetCoordinator?
    var oneTimeSetSizeForBottomSheet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sheet?.handleScrollView(self.scrollView)
        self.sheet?.view.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
    }
    
    func draggableView() -> UIScrollView? {
        return scrollView
    }

    
    func updateDetailBottomSheet(forIndex: Int){
        if let vModel = vModel {
            self.lblHeader.text = vModel.sTypeTitle(forIndex: forIndex)
            self.lblVehicleName.text = vModel.sTypeTitle(forIndex: forIndex)
            self.lblCapacity.text = vModel.vTypeCapacity(forIndex: forIndex)
            self.lblTime.text = vModel.vTypeEta(forIndex: forIndex)
            let fare = vModel.vTypeBaseFareOrEstimate(forIndex: forIndex)
            self.lblVehicleFare.text = fare
            self.lblStartingFare.text = fare
//            cell.capacity.text = (viewModel as! KTCreateBookingViewModel).vTypeCapacity(forIndex: indexPath.row)
//            cell.time.text = (viewModel as! KTCreateBookingViewModel).vTypeEta(forIndex: indexPath.row)
//            cell.icon.image = (viewModel as! KTCreateBookingViewModel).sTypeVehicleImage(forIndex: indexPath.row)
        }
        
//        self.sheet?.handleScrollView(self.scrollView)
    }
    
    @IBAction func btnRequestBookingTouchDown(_ sender: SpringButton){
      springAnimateButtonTapIn(button: btnRequestBooking)
    }
    
    @IBAction func btnRequestBookingTouchUpOutside(_ sender: SpringButton){
      springAnimateButtonTapOut(button: btnRequestBooking)
    }
    
    @IBAction func btnRequestBooking(_ sender: Any){
      springAnimateButtonTapOut(button: btnRequestBooking)
//      (viewModel as! KTCreateBookingViewModel).btnRequestBookingTapped()
    }
}
