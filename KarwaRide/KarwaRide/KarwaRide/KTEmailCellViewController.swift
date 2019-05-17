//
//  KTEmailCellViewController.swift
//  KarwaRide
//
//  Created by Irfan Muhammed on 5/12/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation

class KTEmailCellViewController: UITableViewCell {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    
    var viewModel : KTBaseViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func resendTapped(_ sender: Any) {
        (viewModel as! KTEditUserViewModel).resendEmail()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
