//
//  KTPromotionsBottomSheetVC.swift
//  KarwaRide
//
//  Created by Piecyfer on 18/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import UBottomSheet
import FittedSheets

class KTPromotionsBottomSheetVC: KTBaseViewController, Draggable {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sheet: SheetViewController?
    var sheetCoordinator: UBottomSheetCoordinator?
    private var vModel: KTPromotionsViewModel?
    
    override func viewDidLoad() {
        if viewModel == nil
        {
            viewModel = KTPromotionsViewModel(del: self)
        }
        vModel = viewModel as? KTPromotionsViewModel
        super.viewDidLoad()
        
        self.setupTBL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //adds pan gesture recognizer to draggableView()
        sheetCoordinator?.startTracking(item: self)
    }

//  MARK: Draggable protocol implementations
    func draggableView() -> UIScrollView? {
        return tableView
    }
}

extension KTPromotionsBottomSheetVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTPromotionsViewModel).numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: KTPromotionCell = tableView.dequeueReusableCell(withIdentifier: String(describing: KTPromotionCell.self)) as! KTPromotionCell
        cell.configPromoBottomSheetCell()
        cell.selectionStyle = .none
        animateCell(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    private func setupTBL(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: String(describing: KTPromotionCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: KTPromotionCell.self))
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        }
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
}
