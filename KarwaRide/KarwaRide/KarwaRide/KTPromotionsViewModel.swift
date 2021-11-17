//
//  KTPromotionsViewModel.swift
//  KarwaRide
//
//  Created by Piecyfer on 17/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

protocol KTPromotionsViewModelDelegate {
    func reloadTable()
    func showNoPromotionView()
    func endRefreshing()
}

class KTPromotionsViewModel: KTBaseViewModel {
    
    private var promotions: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        fetchPromotions()
    }
    
    func fetchPromotions()  {
        delegate?.showProgressHud(show: true)
        if (self.promotions?.count ?? 0) > 0 {
            (self.delegate as? KTPromotionsViewModelDelegate)?.reloadTable()
        }
        else {
            (self.delegate as? KTPromotionsViewModelDelegate)?.showNoPromotionView()
        }
        
        (self.delegate as? KTPromotionsViewModelDelegate)?.endRefreshing()
        self.delegate?.hideProgressHud()
    }
    
    func numberOfRows() -> Int {
        return promotions?.count ?? 0
    }
}
