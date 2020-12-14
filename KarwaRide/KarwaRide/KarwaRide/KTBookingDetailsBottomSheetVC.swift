//
//  KTBookingDetailsBottomSheetVC.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/12/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation
import UBottomSheet


class KTBookingDetailsBottomSheetVC: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *)
        {
//            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UINib(nibName: "EmbeddedCell", bundle: nil), forCellReuseIdentifier: "EmbeddedCell")
//        tableView.register(UINib(nibName: "MapItemCell", bundle: nil), forCellReuseIdentifier: "MapItemCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        sheetCoordinator?.startTracking(item: self)
    }
}
