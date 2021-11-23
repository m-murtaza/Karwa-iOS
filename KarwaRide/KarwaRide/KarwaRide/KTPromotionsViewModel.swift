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
    
    func dummyPromotionsData() {
        delegate?.showProgressHud(show: true)
        for i in 1..<6 {
            let promotion = PromotionModel(
                id: i,
                name: "Promo \(i)",
                description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever",
                moreInfo: "Karwa Services are synonymous to public transport in Qatar. Qatar Rail has partnered with Mowasalat (Karwa) through our Karwa Taxi App for hassle free and discounted taxi rides to and from all Metro Stations. Use the “Rail” discount promo code and request you next ride through this App.",
                code: "XYZ12\(i)",
                icon: nil,
                isShowMore: false)
            promotions.append(promotion)
        }
        if self.promotions.count > 0 {
            (self.delegate as? KTPromotionsViewModelDelegate)?.reloadTable()
        }
        else {
            (self.delegate as? KTPromotionsViewModelDelegate)?.showEmptyMessage(message: "str_no_record".localized())
        }
        
        (self.delegate as? KTPromotionsViewModelDelegate)?.endRefreshing()
        self.delegate?.hideProgressHud()
    }
    
    func fetchPromotions() {
        delegate?.showProgressHud(show: true)
        KTPromotionManager().fetchPromotions { [weak self] (status, response) in
            guard let `self` = self else{return}
            (self.delegate as? KTPromotionsViewModelDelegate)?.endRefreshing()
            self.delegate?.showProgressHud(show: false)
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
                    promotionInfo.icon = item["Icon"] as? String
                    
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
    
    func fetchGeoPromotions(pickup: String?, dropoff: String?) {
        guard (pickup != nil || dropoff != nil) else {return}
        delegate?.showProgressHud(show: true)
        KTPromotionManager().fetchGeoPromotions(pickup: pickup, dropoff: dropoff) { [weak self] (status, response) in
            guard let `self` = self else{return}
            self.delegate?.showProgressHud(show: false)
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
                    promotionInfo.icon = item["Icon"] as? String
                    
                    self.promotions.append(promotionInfo)
                }
                
                if self.promotions.count > 0 {
                    (self.delegate as? KTPromotionsViewModelDelegate)?.reloadTable()
                }
                else {
                    (self.delegate as? KTPromotionsViewModelDelegate)?.showEmptyMessage(message: "str_no_record".localized())
                }
            }
            else
            {
                (self.delegate as? KTPromotionsViewModelDelegate)?.showError?(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
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
