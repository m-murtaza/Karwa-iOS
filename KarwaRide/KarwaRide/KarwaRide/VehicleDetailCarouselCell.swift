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
    @IBOutlet weak var imgAccessibleUser : UIImageView!
    @IBOutlet weak var uiPromo: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgVehicleType.isHidden = true
        self.imgAccessibleUser.isHidden = true
    }
    
    func config(vModel: KTCreateBookingViewModel, vehicle: KTVehicleType) {
        imgVehicleType.image = vModel.getTypeVehicleImage(typeId: vehicle.typeId)
        let shouldHidePromoFare = !(vModel.isPromoFare(typeId: vehicle.typeId, fromCarousel: true))
        self.uiPromo.isHidden = shouldHidePromoFare
        if vehicle.typeId == Int16(VehicleType.KTSpecialNeedTaxi.rawValue) {
            self.imgAccessibleUser.isHidden = false
        }
        else {
            self.imgAccessibleUser.isHidden = true
        }
    }
}
