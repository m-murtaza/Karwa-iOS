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
    @IBOutlet weak var lblTotal: SpringLabel!
    @IBOutlet weak var btnRequestBooking: SpringButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnRightArrow: SpringButton!
    @IBOutlet weak var btnLeftArrow: SpringButton!
    @IBOutlet weak var svDetail: UIStackView!
    @IBOutlet weak var uiPreventTouch: UIView!
    
    @IBOutlet weak var heightOFScrollViewContent: NSLayoutConstraint!
    
    var vModel: KTCreateBookingViewModel?
    var vehicles: [KTVehicleType] = []
    var isDataLoaded = false
    var sheet: SheetViewController?
    var sheetCoordinator: UBottomSheetCoordinator?
    var selectedVehicleType: VehicleType?
    var rebook: Bool?
    
    var selectedVehicleIndex = 0
    fileprivate var currentVehicle: Int = 0 {
        didSet {
            if let cell = self.collectionView.cellForItem(at: IndexPath(row: selectedVehicleIndex, section: 0)) as? VehicleDetailCarouselCell {
                cell.imgVehicleType.isHidden = true
            }
            updateDetailBottomSheet(forIndex: currentVehicle)
            btnRightArrow.isHidden = true
            btnLeftArrow.isHidden = true
            if vehicles.count > 1 && vehicles.count != currentVehicle+1 {
                btnRightArrow.isHidden = false
            }
            
            if vehicles.count > 1 && currentVehicle != 0 {
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
        
        btnRightArrow.setImage(UIImage(named: "ic_right_arrow_white")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        btnLeftArrow.setImage(UIImage(named: "ic_left_arrow_white")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
    }
    
    func updateDetailBottomSheet(forIndex: Int = 0){
        selectedVehicleIndex = forIndex
        if let vModel = vModel, !vehicles.isEmpty {
            vModel.selectedVehicleType = VehicleType(rawValue: vehicles[forIndex].typeId)!
            self.lblHeader.text = vModel.getVehicleTitle(vehicleType: vehicles[forIndex].typeId)
            self.lblDescription.text = vModel.getVehicleDescription(vehicleType: vehicles[forIndex].typeId)
            self.lblVehicleName.text = vModel.getVehicleTitle(vehicleType: vehicles[forIndex].typeId)
            self.lblCapacity.text = vModel.getTypeCapacity(typeId: vehicles[forIndex].typeId)
            self.lblTime.text = vModel.getTypeEta(typeId: vehicles[forIndex].typeId)
            let fare = vModel.getTypeBaseFareOrEstimate(typeId: vehicles[forIndex].typeId)
            self.lblVehicleFare.text = fare
            self.lblTotal.text = fare
            
            var orderedBody = vModel.getEstimateOrderedBody(typeId: vehicles[forIndex].typeId)
            if orderedBody == nil {
                orderedBody = vModel.getInitialEstimateOrderedBody(vehicle: vehicles[forIndex])
            }
            svDetail.subviews.forEach({ $0.removeFromSuperview() })
            if let orderedBody = orderedBody {
                svDetail.isHidden = false
                let sheetHeight = CGFloat(470+(15*orderedBody.count)+(self.lblDescription.numberOfLines*10))
                sheet?.setSizes([.fixed(sheetHeight)])
                for i in 0 ..< orderedBody.count {
                    setFarDetails(fareDetail: orderedBody[i], fareBreakDownView: svDetail)
                }
            }
            else {
                svDetail.isHidden = true
                sheet?.setSizes([.fixed(470)])
            }

            if vehicles.count > 1 {
                btnRightArrow.isHidden = false
            }
        }
        if isDataLoaded == false {
            isDataLoaded = true
            collectionView.reloadData()
        }
        animateVehicle(index: currentVehicle)
        self.sheet?.handleScrollView(self.scrollView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (rebook ?? false), let selectedType = self.selectedVehicleType {
            if let vehicleIndex = self.vehicles.firstIndex(where: { type in
                type.typeId == selectedType.rawValue
            }) {
                if vehicleIndex < self.collectionView.numberOfItems(inSection: 0) {
                    self.collectionView.scrollToItem(at: IndexPath(row: vehicleIndex, section: 0), at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
    
    fileprivate func setFarDetails(fareDetail: KTKeyValue, fareBreakDownView: UIStackView ) {
       
        let keyLbl = UILabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        keyLbl.text = fareDetail.key ?? ""
        keyLbl.textAlignment = .right
        keyLbl.textColor = UIColor(hexString: "#434343")
        keyLbl.font = UIFont(name: "MuseoSans-300", size: 10.0)!
        
        let valueLbl = UILabel()
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        valueLbl.text = fareDetail.value ?? "---"
        
        if Device.language().contains("ar") {
            valueLbl.textAlignment = .left
            keyLbl.textAlignment = .right
        } else {
            keyLbl.textAlignment = .left
            valueLbl.textAlignment = .right
        }
        
        valueLbl.textColor = UIColor(hexString: "#434343")
        valueLbl.font = UIFont(name: "MuseoSans-300", size: 10.0)!

        let stackView = UIStackView(arrangedSubviews: [keyLbl, valueLbl])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        fareBreakDownView.addArrangedSubview(stackView)
    }
    
    func setRequestButtonTitle(title: String) {
        self.btnRequestBooking.setTitle(title, for: .normal)
    }
    
    @IBAction func btnRequestBookingTouchDown(_ sender: SpringButton){
        springAnimateButtonTapIn(button: btnRequestBooking)
    }
    
    @IBAction func btnRequestBookingTouchUpOutside(_ sender: SpringButton){
        springAnimateButtonTapOut(button: btnRequestBooking)
    }
    
    @IBAction func btnRequestBooking(_ sender: Any){
        springAnimateButtonTapOut(button: btnRequestBooking)
        vModel?.btnRequestBookingTapped()
    }
    
    @IBAction func onClickRightBtnTouchDown(_ sender: SpringButton){
        springAnimateButtonTapIn(button: btnRightArrow, transform: CGAffineTransform(scaleX: 0.3, y: 0.3))
    }
    
    @IBAction func onClickRightBtnTouchUpOutside(_ sender: SpringButton){
        springAnimateButtonTapOut(button: btnRightArrow)
    }
    
    @IBAction func onClickRightBtn(_ sender: Any){
        setPreventTouchView(show: true)
        springAnimateButtonTapOut(button: btnRightArrow)
        if selectedVehicleIndex != vehicles.count-1 && selectedVehicleIndex+1 < self.collectionView.numberOfItems(inSection: 0) {
            if let cell = self.collectionView.cellForItem(at: IndexPath(row: selectedVehicleIndex, section: 0)) as? VehicleDetailCarouselCell {
                cell.imgVehicleType.isHidden = true
            }
            collectionView.scrollToItem(at: IndexPath(row: selectedVehicleIndex+1, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func onClickLeftBtnTouchDown(_ sender: SpringButton){
        springAnimateButtonTapIn(button: btnLeftArrow, transform: CGAffineTransform(scaleX: 0.3, y: 0.3))
    }
    
    @IBAction func onClickLeftBtnTouchUpOutside(_ sender: SpringButton){
        springAnimateButtonTapOut(button: btnLeftArrow)
    }
    
    @IBAction func onClickLeftBtn(_ sender: Any){
        setPreventTouchView(show: true)
        springAnimateButtonTapOut(button: btnLeftArrow)
        if selectedVehicleIndex != 0 && selectedVehicleIndex-1 < self.collectionView.numberOfItems(inSection: 0) {
            if let cell = self.collectionView.cellForItem(at: IndexPath(row: selectedVehicleIndex, section: 0)) as? VehicleDetailCarouselCell {
                cell.imgVehicleType.isHidden = true
            }
            collectionView.scrollToItem(at: IndexPath(row: selectedVehicleIndex-1, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    private func setPreventTouchView(show: Bool) {
        uiPreventTouch.isHidden = !show
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let `self` = self else {return}
            self.uiPreventTouch.isHidden = show
        }
    }
}

extension VehicleDetailBottomSheetVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vehicles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VehicleDetailCarouselCell.self), for: indexPath) as! VehicleDetailCarouselCell
        cell.config(vModel: self.vModel!, vehicle: vehicles[indexPath.row])
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let `self` = self else {return}
                self.animateVehicle(index: 0)
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let currentItem = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        if selectedVehicleIndex != currentItem {
            currentVehicle = currentItem
        }
    }
    
    func setupCV(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: String(describing: VehicleDetailCarouselCell.self), bundle:nil), forCellWithReuseIdentifier: String(describing: VehicleDetailCarouselCell.self))
        let layout = UPCarouselFlowLayout()
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 0)
        layout.sideItemScale = 0.8
        layout.itemSize = CGSize(width: collectionView.frame.width * 0.8, height: collectionView.frame.height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
    }
    
    func animateVehicle(index: Int) {
        if index < self.collectionView.numberOfItems(inSection: 0), let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? VehicleDetailCarouselCell {
            cell.imgVehicleType.isHidden = false
            cell.imgVehicleType.animation = (Locale.current.languageCode?.contains("ar"))! ? "slideLeft" : "slideRight"
            cell.imgVehicleType.animate()
        }
    }
}

extension UICollectionView {
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + (self.bounds.size.width * 0.8)))
        self.moveToFrame(contentOffset: contentOffset)
    }

    func scrollToPreviousItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x - (self.bounds.size.width * 0.8)))
        self.moveToFrame(contentOffset: contentOffset)
    }

    func moveToFrame(contentOffset : CGFloat) {
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
}
