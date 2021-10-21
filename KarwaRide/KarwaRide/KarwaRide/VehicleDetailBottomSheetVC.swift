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
    @IBOutlet weak var btnRightArrow: UIButton!
    @IBOutlet weak var btnLeftArrow: UIButton!
    
    @IBOutlet weak var heightOFScrollViewContent: NSLayoutConstraint!
    
    var vModel: KTCreateBookingViewModel?
    var sheet: SheetViewController?
    var sheetCoordinator: UBottomSheetCoordinator?
    
    var vehicleListCount = 4
    var selectedVehicleIndex = 0
    fileprivate var currentVehicle: Int = 0 {
        didSet {
            animateVehicle(index: currentVehicle)
            btnRightArrow.isHidden = true
            btnLeftArrow.isHidden = true
            if vehicleListCount > 1 && vehicleListCount != currentVehicle+1 {
                btnRightArrow.isHidden = false
            }
            
            if vehicleListCount > 1 && currentVehicle != 0 {
                btnLeftArrow.isHidden = false
            }
        }
    }
    fileprivate var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    var screenSize: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.main.bounds
        self.sheet?.handleScrollView(self.scrollView)
        self.sheet?.view.backgroundColor = .clear
        self.setupView()
        self.setupCV()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
    }
    
    func draggableView() -> UIScrollView? {
        return scrollView
    }

    private func setupView(){
        btnRightArrow.isHidden = true
        btnLeftArrow.isHidden = true
    }
    
    func updateDetailBottomSheet(forIndex: Int){
        selectedVehicleIndex = forIndex
        if let vModel = vModel {
            self.lblHeader.text = vModel.sTypeTitle(forIndex: forIndex)
            self.lblVehicleName.text = vModel.sTypeTitle(forIndex: forIndex)
            self.lblCapacity.text = vModel.vTypeCapacity(forIndex: forIndex)
            self.lblTime.text = vModel.vTypeEta(forIndex: forIndex)
            let fare = vModel.vTypeBaseFareOrEstimate(forIndex: forIndex)
            self.lblVehicleFare.text = fare
            self.lblStartingFare.text = fare
            
            collectionView.reloadData()
            
            if vehicleListCount > 1 {
                btnRightArrow.isHidden = false
            }
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
    
    @IBAction func onClickRightBtn(_ sender: UIButton){
//        if selectedVehicleIndex != vehicleListCount-1 && selectedVehicleIndex+1 < self.collectionView.numberOfItems(inSection: 0) {
//            self.collectionView.scrollToItem(at: IndexPath(row: selectedVehicleIndex+1, section: 0), at: .right, animated: true)
//        }
    }
    
    @IBAction func onClickLeftBtn(_ sender: UIButton){
//        if selectedVehicleIndex != 0 && selectedVehicleIndex-1 < self.collectionView.numberOfItems(inSection: 0) {
//            self.collectionView.scrollToItem(at: IndexPath(row: selectedVehicleIndex-1, section: 0), at: .right, animated: true)
//        }
    }
}

extension VehicleDetailBottomSheetVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VehicleDetailCarouselCell.self), for: indexPath) as! VehicleDetailCarouselCell
        cell.config(vModel: self.vModel!, index: selectedVehicleIndex)
        return cell
    }
}

extension VehicleDetailBottomSheetVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.8, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let `self` = self else {return}
                self.animateVehicle(index: 0)
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentVehicle = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    func setupCV(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: String(describing: VehicleDetailCarouselCell.self), bundle:nil), forCellWithReuseIdentifier: String(describing: VehicleDetailCarouselCell.self))
        let layout = UPCarouselFlowLayout()
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 0)
        layout.sideItemScale = 0.8
        layout.itemSize = CGSize(width: collectionView.frame.width * 0.8,
        height: collectionView.frame.height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
    }
    
    func animateVehicle(index: Int) {
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? VehicleDetailCarouselCell {
            cell.imgVehicleType.animation = (Locale.current.languageCode?.contains("ar"))! ? "slideLeft" : "slideRight"
            cell.imgVehicleType.animate()
        }
    }
}
