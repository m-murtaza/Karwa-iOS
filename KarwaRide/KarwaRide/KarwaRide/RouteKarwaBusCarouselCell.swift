//
//  RouteKarwaBusCarouselCell.swift
//  KarwaRide
//
//  Created by Apple on 02/02/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import Foundation
import ScalingCarousel
import Spring

class RouteKarwaBusCarouselCell: UICollectionViewCell {
    
    @IBOutlet weak var busNumberLbl: PaddingLabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var rideToAddressLbl: UILabel!
    @IBOutlet weak var rideToTimeLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
