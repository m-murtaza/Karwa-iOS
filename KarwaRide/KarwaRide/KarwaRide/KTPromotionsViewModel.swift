//
//  KTPromotionsViewModel.swift
//  KarwaRide
//
//  Created by Piecyfer on 17/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

protocol KTPromotionsViewModelDelegate: KTViewModelDelegate {
    func reloadTable()
    func showEmptyMessage(message: String)
    func endRefreshing()
}

extension KTPromotionsViewModelDelegate {
    func showEmptyMessage(message: String) {}
    func endRefreshing() {}
}

class KTPromotionsViewModel: KTBaseViewModel {
    
    private var promotions = [PromotionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    func fetchPromotions(params: PromotionParams? = nil) {
        KTPromotionManager().fetchPromotions(params: params) { [weak self] (status, response) in
            guard let `self` = self else{return}
            (self.delegate as? KTPromotionsViewModelDelegate)?.endRefreshing()
            if status == Constants.APIResponseStatus.SUCCESS
            {
                guard let promotions = response[Constants.ResponseAPIKey.Data] as? [[String : Any]] else {
                    (self.delegate as? KTPromotionsViewModelDelegate)?.showEmptyMessage(message: "str_no_record".localized())
                    return
                }
                for item in promotions {
                    var promotionInfo = PromotionModel()
                    
                    promotionInfo.id = item["Id"] as? Int
                    promotionInfo.name = item["Name"] as? String
                    promotionInfo.description = item["Description"] as? String
                    promotionInfo.moreInfo = item["MoreInfo"] as? String
                    promotionInfo.code = item["Code"] as? String
                    let iconUrl = KTConfiguration.sharedInstance.envValue(forKey: Constants.API.BaseURLKey) + Constants.APIURL.PromotionIcon + String(promotionInfo.id!)
                    promotionInfo.icon = iconUrl
                    
                    self.promotions.append(promotionInfo)
                }
                
                (self.delegate as? KTPromotionsViewModelDelegate)?.reloadTable()
                if self.promotions.count > 0 {
                    (self.delegate as? KTPromotionsViewModelDelegate)?.showEmptyMessage(message: "")
                }
                else {
                    (self.delegate as? KTPromotionsViewModelDelegate)?.showEmptyMessage(message: "str_no_record".localized())
                }
            }
            else
            {
                (self.delegate as? KTPromotionsViewModelDelegate)?.showError?(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                (self.delegate as? KTPromotionsViewModelDelegate)?.showEmptyMessage(message: "str_no_record".localized())
            }
        }
    }
    
    func numberOfRows() -> Int {
        return promotions.count
    }
    
    func getPromotion(at index: Int) -> PromotionModel {
        guard promotions.count > index else {return PromotionModel()}
        return promotions[index]
    }
    
    
    func getShowMore(at index: Int) -> Bool {
        guard promotions.count > index else {return false}
        return promotions[index].isShowMore
    }
    
    func setShowMore(at index: Int, value: Bool) {
        guard promotions.count > index else {return}
        promotions[index].isShowMore = value
    }
}
