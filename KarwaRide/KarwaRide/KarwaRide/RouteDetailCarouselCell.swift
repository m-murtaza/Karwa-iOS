//
//  RouteDetailCarouselCell.swift
//  KarwaRide
//
//  Created by Apple on 02/02/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import Foundation
import ScalingCarousel
import Spring

class RouteDetailCarouselCell: UICollectionViewCell {
    @IBOutlet weak var imgLegTypeView : SpringImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(vModel: KTCreateBookingViewModel, vehicle: KTVehicleType) {
        
    }
}
