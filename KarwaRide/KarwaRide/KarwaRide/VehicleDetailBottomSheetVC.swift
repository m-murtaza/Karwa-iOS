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

class VehicleDetailBottomSheetVC: UIViewController, Draggable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var lblHeader: LocalisableSpringLabel!
    @IBOutlet weak var lblDescription: SpringLabel!
    @IBOutlet weak var lblVehicleName: SpringLabel!
    
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
//            let fare = (viewModel as! KTCreateBookingViewModel).vTypeBaseFareOrEstimate(forIndex: indexPath.row)
//            cell.setFare(fare: fare)
//            cell.capacity.text = (viewModel as! KTCreateBookingViewModel).vTypeCapacity(forIndex: indexPath.row)
//            cell.time.text = (viewModel as! KTCreateBookingViewModel).vTypeEta(forIndex: indexPath.row)
//            cell.icon.image = (viewModel as! KTCreateBookingViewModel).sTypeVehicleImage(forIndex: indexPath.row)
        }
        
//        self.sheet?.handleScrollView(self.scrollView)
//
//        self.view.backgroundColor = UIColor.clear
//        self.view.customCornerRadius = 20.0
//
//        DispatchQueue.main.async {
//            self.heightOFScrollViewContent.constant = 550
//            if UIDevice().userInterfaceIdiom == .phone {
//                switch UIScreen.main.nativeBounds.height {
//                case 1136:
//                    print("iPhone 5 or 5S or 5C")
//                    self.sheet?.setSizes([.percent(0.35),.intrinsic], animated: true)
//                case 1334:
//                    print("iPhone 6/6S/7/8")
//                    self.sheet?.setSizes([.percent(0.35),.intrinsic], animated: true)
//                case 1920, 2208:
//                    print("iPhone 6+/6S+/7+/8+")
//                    self.sheet?.setSizes([.percent(0.30),.intrinsic], animated: true)
//                case 2436:
//                    print("iPhone X")
//                    self.sheet?.setSizes([.percent(0.25),.intrinsic], animated: true)
//                default:
//                    print("unknown")
//                    self.sheet?.setSizes([.percent(0.25),.intrinsic], animated: true)
//                }
//            }
//        }
    }
}



