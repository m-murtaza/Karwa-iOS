//
//  KTCreateBookingViewController+CarouselView.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import ScalingCarousel
import Spring

class KTServiceCardCell: ScalingCarouselCell {
    
    @IBOutlet weak var lblServiceType : UILabel!
    @IBOutlet weak var lblBaseFareOrEstimate : UILabel!
    @IBOutlet weak var imgBg : UIImageView!
    @IBOutlet weak var imgVehicleType : UIImageView!
    @IBOutlet weak var lblFareEstimateTitle : UILabel!
    @IBOutlet weak var promoBadge: SpringImageView!
}

extension KTCreateBookingViewController {
    
    func updateVehicleTypeList () {
        
        self.carousel.reloadData()
    }
    
    func setVehicleType(idx: Int) {
        
        carousel.scrollToItem(at:IndexPath(item: idx, section: 0), at: .right, animated: false)
    }
}

typealias CarouselDatasource = KTCreateBookingViewController
extension CarouselDatasource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel as! KTCreateBookingViewModel).numberOfRowsVType()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let sTypeCell = cell as? KTServiceCardCell {
            sTypeCell.lblServiceType.text = (viewModel as! KTCreateBookingViewModel).sTypeTitle(forIndex: indexPath.row)
            
            sTypeCell.lblBaseFareOrEstimate.text = (viewModel as! KTCreateBookingViewModel).vTypeBaseFareOrEstimate(forIndex: indexPath.row)
            sTypeCell.lblFareEstimateTitle.text = (viewModel as! KTCreateBookingViewModel).FareEstimateTitle()
            sTypeCell.imgBg.image = (viewModel as! KTCreateBookingViewModel).sTypeBackgroundImage(forIndex: indexPath.row)
            sTypeCell.imgVehicleType.image = (viewModel as! KTCreateBookingViewModel).sTypeVehicleImage(forIndex: indexPath.row)
            sTypeCell.promoBadge.isHidden = !((viewModel as! KTCreateBookingViewModel).isPromoFare(forIndex: indexPath.row))
        }
        
        return cell
    }
}

typealias CarouselDelegate = KTCreateBookingViewController
extension CarouselDelegate: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (viewModel as! KTCreateBookingViewModel).vehicleTypeTapped(idx: indexPath.row)
        //self.veiwFareBreakdown.isHidden = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        carousel.didScroll()
        
        guard (carousel.currentCenterCellIndex?.row) != nil , allowScroll == true else {
            return
            
        }
        (viewModel as! KTCreateBookingViewModel).vTypeViewScroll(currentIdx: carousel.currentCenterCellIndex!.row)
    }
    //Total Jugar: for some reason scrollViewDidScroll(above method) was getting called when view disappears and change index for standard limo. Why only standard limo? coz its very near from first index. others take time while standard limo didn't take time. 
    func allowScrollVTypeCard(allow : Bool) {
        allowScroll = allow
    }
}

