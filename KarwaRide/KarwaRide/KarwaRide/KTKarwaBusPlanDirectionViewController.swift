//
//  KTKarwaBusPlanDirectionViewController.swift
//  KarwaRide
//
//  Created by Apple on 01/02/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout
import Spring
import GoogleMaps

class KTKarwaBusPlanDirectionViewController: KTBaseViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var mapToggleBtn: SpringButton!
    @IBOutlet weak var bottomCarouselView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView : GMSMapView!
    var itenary: Itinerary?
    let busStoryboard = UIStoryboard(name: "BusStoryBoard", bundle: .main)

    var screenSize: CGRect!
    var widthRatio = 0.8
    var selectedIndex = 0

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupCV()
        }
        self.addMap()
    }
    
    func setupCV(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: String(describing: RouteDetailCarouselCell.self), bundle:nil), forCellWithReuseIdentifier: String(describing: RouteDetailCarouselCell.self))
        collectionView.register(UINib(nibName: String(describing: RouteWalkCarouselCell.self), bundle:nil), forCellWithReuseIdentifier: String(describing: RouteWalkCarouselCell.self))
        collectionView.register(UINib(nibName: String(describing: RouteKarwaBookCarouselCell.self), bundle:nil), forCellWithReuseIdentifier: String(describing: RouteKarwaBookCarouselCell.self))
        collectionView.register(UINib(nibName: String(describing: RouteKarwaBusCarouselCell.self), bundle:nil), forCellWithReuseIdentifier: String(describing: RouteKarwaBusCarouselCell.self))

        let layout = UPCarouselFlowLayout()
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 10)
        layout.sideItemScale = 0.8
        layout.sideItemAlpha = 1.0
        layout.itemSize = CGSize(width: collectionView.frame.width * widthRatio, height: collectionView.frame.height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        self.pageControl.numberOfPages = (self.itenary?.legs?.count ?? 0) + 1
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    @IBAction func toggleDirectionView(_ sender: UIButton) {
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func panView(_ gesture: UIPanGestureRecognizer) {
//        // 1
//        let translation = gesture.translation(in: view)
//
//        // 2
//        guard let gestureView = gesture.view else {
//            return
//        }
//
//        print("gestureView.center.y", gestureView.center.y)
//        print("translation.y", translation.y)
//        // in these two cases, don't translate the image view
//        print("self.view.frame.height", self.view.frame.height)
//
//        // clamping the translated y
//        gestureView.center.y = min(max(gestureView.center.y + translation.y, 475), 900)
//        gesture.setTranslation(.zero, in: view)
//
//        let percentage = CGFloat(gestureView.frame.origin.y / (self.view.frame.size.height - 135.0));
//
//        print("percentage", percentage)
//
//        print("draggableView.origin.y", draggableView.frame.origin.y)
//
//        topAddressHeaderView.alpha =  1.0 - percentage //min(max(gestureView.center.y + translation.y, 161), 900)
//
//        print("topAddressHeaderView.alpha", topAddressHeaderView.alpha)
    }

}

extension KTKarwaBusPlanDirectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (itenary?.legs?.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RouteDetailCarouselCell.self), for: indexPath) as! RouteDetailCarouselCell
            cell.bgView.backgroundColor = UIColor.white
            cell.titleLabel.text = "Start from"
            cell.addressLabel.text = suggestedRoutes.plan?.from?.name ?? ""
            let date = Date(timeIntervalSince1970: TimeInterval(Double(suggestedRoutes.plan?.date ?? 0)))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a dd MMM yyyy"
            let dateString = dateFormatter.string(from: date)
            cell.timeLabel.text = "Departs at \(dateString)"
            return cell
        } else {
            if let leg = itenary?.legs?[indexPath.row - 1] {
                
                if leg.mode! == "WALK" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RouteWalkCarouselCell.self), for: indexPath) as! RouteWalkCarouselCell
                    cell.titleLabel.text = "Walk to"
                    cell.addressLabel.text = leg.to?.name ?? ""
                    cell.timeLabel.text = "\(Int(leg.distance ?? 0)) m • \((leg.duration ?? 0)/60) min"
                    return cell
                } else if leg.mode! == "BUS" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RouteKarwaBusCarouselCell.self), for: indexPath) as! RouteKarwaBusCarouselCell
                    cell.busNumberLbl.addLeading(image: UIImage(named: "BusListing")!, text: "\(leg.routeShortName ?? "") ", imageOffsetY: 0)
                    cell.busNumberLbl.customBorderColor = UIColor(hexString: "\(leg.routeColor ?? "")")
                    cell.addressLbl.text = leg.from?.name ?? ""
                    let date = Date(timeIntervalSince1970: TimeInterval(Double(suggestedRoutes.plan?.date ?? 0)))
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a dd MMM yyyy"
                    let dateString = dateFormatter.string(from: date)
                    cell.timeLbl.text = "Departs at \(dateString)"
                    
                    let departTime = Date(timeIntervalSince1970: TimeInterval(Double(leg.from?.departure ?? 0)))
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "h:mm a dd/mm/yyyy"
                    let timeString = timeFormatter.string(from: departTime)
                    
                    let arrivalTime = Date(timeIntervalSince1970: TimeInterval(Double(leg.from?.arrival ?? 0)))
                    let arrivalTimeFormatter = DateFormatter()
                    arrivalTimeFormatter.dateFormat = "h:mm a dd/mm/yyyy"
                    let arrtimeString = arrivalTimeFormatter.string(from: arrivalTime)
                    
                    cell.timeLbl.text = "\(timeString) - \(arrtimeString)"
                    cell.rideToAddressLbl.text = leg.to?.name ?? ""
                    cell.rideToTimeLbl.text = "\(Int(leg.distance ?? 0)) m • \((leg.duration ?? 0)/60) min"
                    return cell
                }
            }
        }
        
        return UICollectionViewCell()
        
    }
}

extension KTKarwaBusPlanDirectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * widthRatio, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.animateLegType(index: indexPath.row)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let currentItem = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        self.pageControl.currentPage = currentItem
        if selectedIndex != currentItem {
            selectedIndex = currentItem
        }
//        
//        if selectedIndex == 0 {
//            
//        }
//        
//        if let leg = itenary?.legs?[selectedIndex] {
//            if let path = GMSMutablePath(fromEncodedPath: leg.legGeometry?.points ?? "") {
//                path.coordinate(at:0)
//                let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(path.coordinate(at:0), zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
//                self.mapView.animate(with: update)
//            }
//        }
        
        
    }
        
    func animateLegType(index: Int) {
        if index < self.collectionView.numberOfItems(inSection: 0), let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? RouteWalkCarouselCell {
            cell.imgLegTypeView.isHidden = false
            cell.imgLegTypeView.animation = (Locale.current.languageCode?.contains("ar"))! ? "slideLeft" : "slideRight"
            cell.imgLegTypeView.animate()
        }
    }
    
    @IBAction func onClickRightBtn(_ sender: UIButton) {
        if selectedIndex < collectionView(collectionView, numberOfItemsInSection: 0) - 1 {
            collectionView.scrollToItem(at: IndexPath(item: selectedIndex+1, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func onClickLeftBtn(_ sender: UIButton) {
        if selectedIndex != 0 {
            collectionView.scrollToItem(at: IndexPath(item: selectedIndex-1, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}

class FilterPresentationController: UIPresentationController {
  // MARK: Properties
  
  let blurEffectView: UIVisualEffectView!
  var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
  
  // 1.
  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
      let blurEffect = UIBlurEffect(style: .regular)
      blurEffectView = UIVisualEffectView(effect: blurEffect)
      super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
      tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.blurEffectView.isUserInteractionEnabled = true
      self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  // 2.
  override var frameOfPresentedViewInContainerView: CGRect {
      CGRect(origin: CGPoint(x: 0, y: 130),
             size: CGSize(width: self.containerView!.frame.width, height: self.containerView!.frame.height - 130))
  }

  // 3.
  override func presentationTransitionWillBegin() {
      self.blurEffectView.alpha = 0
      self.containerView?.addSubview(blurEffectView)
      self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
          self.blurEffectView.alpha = 0.1
      }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
  }
  
  // 4.
  override func dismissalTransitionWillBegin() {
      self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
          self.blurEffectView.alpha = 0
      }, completion: { (UIViewControllerTransitionCoordinatorContext) in
          self.blurEffectView.removeFromSuperview()
      })
  }
  
  // 5.
  override func containerViewWillLayoutSubviews() {
      super.containerViewWillLayoutSubviews()
  }

  // 6.
  override func containerViewDidLayoutSubviews() {
      super.containerViewDidLayoutSubviews()
      presentedView?.frame = frameOfPresentedViewInContainerView
      blurEffectView.frame = containerView!.bounds
  }

  // 7.
    @objc func dismissController(_ gesture: UIGestureRecognizer){
      self.presentedViewController.dismiss(animated: true, completion: nil)
  }
}
