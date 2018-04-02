//
//  KTCreateBookingViewController+CarouselView.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/2/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import ScalingCarousel

class KTServiceCardCell: ScalingCarouselCell {
    
    @IBOutlet weak var lblServiceType : UILabel!
    @IBOutlet weak var lblBaseFare : UILabel!
    @IBOutlet weak var imgBg : UIImageView!
    @IBOutlet weak var imgVehicleType : UIImageView!
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
            
            sTypeCell.lblBaseFare.text = (viewModel as! KTCreateBookingViewModel).sTypeBaseFare(forIndex: indexPath.row)
            sTypeCell.imgBg.image = (viewModel as! KTCreateBookingViewModel).sTypeBackgroundImage(forIndex: indexPath.row)
            sTypeCell.imgVehicleType.image = (viewModel as! KTCreateBookingViewModel).sTypeVehicleImage(forIndex: indexPath.row)
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
        
        guard (carousel.currentCenterCellIndex?.row) != nil else { return }
        (viewModel as! KTCreateBookingViewModel).vTypeViewScroll(currentIdx: carousel.currentCenterCellIndex!.row)
    }
}

