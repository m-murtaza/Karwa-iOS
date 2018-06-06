//
//  cancelReasonTableViewCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTCancelReasonCellDelegate {
    func optionSelected(atIdx idx: Int)
}

class KTCancelReasonTableViewCell: UITableViewCell {
    
    var delegate : KTCancelReasonCellDelegate?
    
    @IBOutlet var lblReason: UILabel?
    @IBOutlet var btnSelection : UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btnSelectionTapped(_ sender: Any) {
        
        let tag : Int = (btnSelection?.tag)!
        delegate?.optionSelected(atIdx: tag)
    }
    
    func cancelOptionSelected(tag:Int) {
        delegate?.optionSelected(atIdx: tag)
    }
}
