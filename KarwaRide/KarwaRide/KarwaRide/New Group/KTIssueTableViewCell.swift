//
//  KTIssueTableViewCell.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/11/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

class KTIssueTableViewCell: UITableViewCell {
    
    @IBOutlet weak var issueName: UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

