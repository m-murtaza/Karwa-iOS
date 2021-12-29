//
//  AddressPickCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol AddressPickerCellDelegate: AnyObject {
    func btnMoreTapped(withTag: Int)
}

class AddressPickCell: UITableViewCell {

    @IBOutlet weak var addressTitle : UILabel!
    @IBOutlet weak var addressArea : UILabel!
    @IBOutlet weak var ImgTypeIcon : UIImageView!
    @IBOutlet weak var btnMore: UIButton!
    var delegate : AddressPickerCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnMoreTapped(_ sender: Any) {
        
        //TODO: Show action sheet. As discussed with Danish bahi
        self.delegate?.btnMoreTapped(withTag: btnMore.tag)
    }

}
