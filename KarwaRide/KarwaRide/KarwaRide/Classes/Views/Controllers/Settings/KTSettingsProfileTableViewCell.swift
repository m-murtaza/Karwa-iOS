//
//  KTSettingsProfileTableViewCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/27/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTSettingsProfileTableViewCell: UITableViewCell {

    @IBOutlet private weak var lblName : UILabel!
    @IBOutlet private weak var lblPhone : UILabel!
    @IBOutlet private weak var lblShortName : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUserInfo(name : String, phone : String) {
        
        lblName.text = name
        lblPhone.text = phone
        lblShortName.text = getShortName(name: name)
    }

    func getShortName(name: String) -> String {
        var fullNameArr = name.components(separatedBy: " ")
        let firstName: String = fullNameArr[0]
        var lastName: String = ""
        if fullNameArr.count > 1 {
            lastName = fullNameArr[1]
        }

        return  (firstLetter(sth:firstName) + firstLetter(sth:lastName)).uppercased()
        
    }
    
    func firstLetter(sth: String)->String{
        return String(sth.first!)
    }
}
