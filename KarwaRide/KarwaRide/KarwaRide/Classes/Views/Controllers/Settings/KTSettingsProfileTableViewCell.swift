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
    @IBOutlet weak var circularProgress: CircularProgress!
    @IBOutlet weak var warningImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    fileprivate func initCircularProgressBar(_ completeness: Int)
    {
        circularProgress.lineWidth = 3.0
        circularProgress.labelSize = 12
        circularProgress.safePercent = 100
        
        let completeness = Float(completeness) / 100
        
        circularProgress.setProgress(to: Double(completeness), withAnimation: true)
    }
    
    func setUserInfo(name : String, phone : String, completeness: Int, emailVerified: Bool)
    {
        UIView.animate(withDuration: 0.5, animations: {
            self.lblName.text = name
            self.lblPhone.text = phone
            self.warningImg.isHidden = emailVerified
        })
     
        //Initializing it twice because of bug in the Circular Progress View, disappearing after first animation
        initCircularProgressBar(completeness)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            self.initCircularProgressBar(completeness)
        }
    }

//    func getShortName(name: String) -> String {
//        var fullNameArr = name.components(separatedBy: " ")
//        let firstName: String = fullNameArr[0]
//        var lastName: String = ""
//        if fullNameArr.count > 1 {
//            lastName = fullNameArr[1]
//        }
//
//        return  (firstLetter(sth:firstName) + firstLetter(sth:lastName)).uppercased()
//        
//    }
    
    func firstLetter(sth: String)->String{
        var first : String = ""
        if !sth.isEmpty{
            first = String(sth.first!)
        }
        return first
    }
}
