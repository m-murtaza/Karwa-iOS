//
//  KTSettingCalendarTableViewCell.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/27/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import JTMaterialSwitch

class KTSettingCalendarTableViewCell: KTSettingsImgTextTableViewCell {

    var onOffSwitch : JTMaterialSwitch?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        onOffSwitch = JTMaterialSwitch(size: JTMaterialSwitchSizeNormal, style: JTMaterialSwitchStyleLight, state: JTMaterialSwitchStateOff)
        //onOffSwitch?.center = CGPoint(x: 0, y: 0)
        //onOffSwitch?.sty
        onOffSwitch?.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch) {
        print("Switch Value change")
    }

}
