//
//  KTMyTripsCellTableViewCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/13/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTMyTripsTableViewCell: UITableViewCell {
  
  @IBOutlet weak var pickupAddressLabel : UILabel!
  @IBOutlet weak var dropoffAddressLabel : UILabel!
  @IBOutlet weak var outerContainer : KTShadowView!
  @IBOutlet weak var innerContainer : KTShadowView!
  @IBOutlet weak var timeLabel : UILabel!
  @IBOutlet weak var dateLabel : UILabel!
  @IBOutlet weak var serviceTypeLabel : UILabel!
  @IBOutlet weak var capacityLabel : UILabel!
  @IBOutlet weak var statusLabel : UILabel!
  @IBOutlet weak var cashIcon : UIImageView!
  @IBOutlet weak var detailArrow : UIImageView!
  @IBOutlet weak var cancellationChargeLabel : UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
      self.selectionStyle = .none
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
      if selected {
          self.outerContainer.backgroundColor = UIColor.groupTableViewBackground
          self.innerContainer.backgroundColor = .groupTableViewBackground
      } else {
          self.outerContainer.backgroundColor = .white
          self.innerContainer.backgroundColor = .white
      }
    // Configure the view for the selected state
  }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.outerContainer.backgroundColor = .groupTableViewBackground
            self.innerContainer.backgroundColor = .groupTableViewBackground
        } else {
            self.outerContainer.backgroundColor = .white
            self.innerContainer.backgroundColor = .white
        }
    }
  
}
