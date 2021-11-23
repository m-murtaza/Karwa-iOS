//
//  KTPromotionCell.swift
//  KarwaRide
//
//  Created by Piecyfer on 18/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

class KTPromotionCell: UITableViewCell {
    @IBOutlet weak var uiMain: ViewWithRoundCorner!
    @IBOutlet weak var uiDetailView: UIView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var lblSeeMore: UILabel!
    @IBOutlet weak var imgPromotion: UIImageView!
    
    var index: IndexPath?
    var isShowMore = false
    var onClickShowMore: ((Bool, _ index: IndexPath)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.uiDetailView.isHidden = true
        self.uiMain.borderWidth = 0
        self.setupShowMoreGesture()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(isSelected: Bool, data: PromotionModel) {
        self.uiMain.borderWidth = isSelected ? 2 : 0
        self.uiDetailView.isHidden = !isShowMore
        let showMoreText = isShowMore ? "str_show_less".localized() : "str_show_more".localized()
        if let attributedString = createAttributedString(stringArray: [showMoreText], attributedPart: 1, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "MuseoSans-700", size: 9.0)!, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]) {
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSRange.init(location: 0, length: attributedString.length))
            self.lblSeeMore.attributedText = attributedString
        }
        self.lblCode.text = "str_code".localized() + ": \(data.code ?? "")"
        self.lblHeading.text = data.name
        self.lblSubHeading.text = data.description
        self.lblDetail.text = data.moreInfo
//        self.imgPromotion.image = data.icon?.base64ToImage()
    }
    
    func configPromoBottomSheetCell(data: PromotionModel) {
        self.uiMain.borderWidth = 1
        self.uiMain.cornerRadius = 14
        self.uiDetailView.isHidden = true
        self.lblSeeMore.isHidden = true
        
        self.lblCode.text = "str_code".localized() + ": \(data.code ?? "")"
        self.lblHeading.text = data.name
        self.lblSubHeading.text = data.description
        self.lblDetail.text = data.moreInfo
//        self.imgPromotion.image = data.icon?.base64ToImage()
    }
    
    func setupShowMoreGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onShowMoreTapped(_:)))
        self.lblSeeMore.isUserInteractionEnabled = true
        self.lblSeeMore.addGestureRecognizer(tapGesture)
    }
    
    @objc func onShowMoreTapped(_ sender: UITapGestureRecognizer) {
        self.onClickShowMore?(isShowMore, self.index!)
    }
}
