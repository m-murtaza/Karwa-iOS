//
//  RouteWalkCarouselCell.swift
//  KarwaRide
//
//  Created by Apple on 02/02/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import Foundation
import ScalingCarousel
import Spring

class RouteWalkCarouselCell: UICollectionViewCell {
    
    @IBOutlet weak var imgLegTypeView : SpringImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(vModel: KTCreateBookingViewModel) {
        
    }
}
