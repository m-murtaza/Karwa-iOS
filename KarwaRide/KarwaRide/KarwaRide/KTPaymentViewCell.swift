//
//  KTPaymentViewCell.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/30/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTPaymentViewCell: UITableViewCell {

    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardExpiry: UILabel!
    @IBOutlet weak var cellBackground: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        let mScreenSize = UIScreen.main.bounds
//        let mSeparatorHeight = CGFloat(10.0) // Change height of speatator as you want
//        let mAddSeparator = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height - mSeparatorHeight, width: mScreenSize.width, height: mSeparatorHeight))
//        mAddSeparator.backgroundColor = UIColor.white // Change backgroundColor of separator
//        self.addSubview(mAddSeparator)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
