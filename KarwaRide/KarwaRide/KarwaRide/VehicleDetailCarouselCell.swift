//
//  VehicleDetailCarouselCell.swift
//  KarwaRide
//
//  Created by Piecyfer on 20/10/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation
import ScalingCarousel
import Spring

class VehicleDetailCarouselCell: UICollectionViewCell {
    @IBOutlet weak var imgBg : UIImageView!
    @IBOutlet weak var imgVehicleType : SpringImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(vModel: KTCreateBookingViewModel, vehicle: KTVehicleType) {
        imgVehicleType.image = vModel.getTypeVehicleImage(typeId: vehicle.typeId)
    }
}
