//
//  KTBookingDetailsBottomSheetVC.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/12/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation
import UBottomSheet


class KTBookingDetailsBottomSheetVC: UIViewController, Draggable
{
    var vModel : KTBookingDetailsViewModel?

    var sheetCoordinator: UBottomSheetCoordinator?

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        sheetCoordinator?.startTracking(item: self)
    }
}
