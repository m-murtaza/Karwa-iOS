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
    let busStoryboard = UIStoryboard(name: "BusStoryBoard", bundle: .main)

    var screenSize: CGRect!
    var widthRatio = 0.8
    var selectedIndex = 0
    var showList = true

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
        let layout = UPCarouselFlowLayout()
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 10)
        layout.sideItemScale = 0.8
        layout.sideItemAlpha = 1.0
        layout.itemSize = CGSize(width: collectionView.frame.width * widthRatio, height: collectionView.frame.height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        self.pageControl.numberOfPages = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showList = true
    }
    
    @objc func setMapView() {
        if #available(iOS 13.0, *) {
            mapToggleBtn.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        showList = true
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

extension KTKarwaBusPlanDirectionViewController: UIViewControllerTransitioningDelegate {
    // 2.
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        FilterPresentationController(presentedViewController: presented, presenting: presenting)
    }
}


extension KTKarwaBusPlanDirectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row % 2 == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RouteDetailCarouselCell.self), for: indexPath) as! RouteDetailCarouselCell
            return cell
        } else if indexPath.row % 3 == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RouteWalkCarouselCell.self), for: indexPath) as! RouteWalkCarouselCell
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RouteKarwaBookCarouselCell.self), for: indexPath) as! RouteKarwaBookCarouselCell
            return cell
        }
        
        
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
