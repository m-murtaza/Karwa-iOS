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
import UPCarouselFlowLayout

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
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var heightOFScrollViewContent: NSLayoutConstraint!
    
    var vModel: KTCreateBookingViewModel?
    var sheet: SheetViewController?
    var sheetCoordinator: UBottomSheetCoordinator?
    var oneTimeSetSizeForBottomSheet = false
    var screenSize: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.main.bounds
        self.sheet?.handleScrollView(self.scrollView)
        self.sheet?.view.backgroundColor = .clear
        self.setupCV()
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
        collectionView.reloadData()
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

extension VehicleDetailBottomSheetVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VehicleDetailCarouselCell.self), for: indexPath) as! VehicleDetailCarouselCell

        return cell
    }
}

extension VehicleDetailBottomSheetVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        (viewModel as! KTCreateBookingViewModel).vehicleTypeTapped(idx: indexPath.row)
        //self.veiwFareBreakdown.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.8, height: collectionView.frame.height)
    }
    
    func setupCV(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: String(describing: VehicleDetailCarouselCell.self), bundle:nil), forCellWithReuseIdentifier: String(describing: VehicleDetailCarouselCell.self))
        let layout = UPCarouselFlowLayout()
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 10)
        layout.sideItemScale = 0.8
        layout.itemSize = CGSize(width: collectionView.frame.width * 0.8,
        height: collectionView.frame.height)
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }
}

extension VehicleDetailBottomSheetVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}
