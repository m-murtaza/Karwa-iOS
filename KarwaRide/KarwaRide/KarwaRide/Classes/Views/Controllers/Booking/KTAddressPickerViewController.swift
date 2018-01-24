//
//  KTAddressPickerViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/23/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTAddressPickerViewController: KTBaseViewController {
    
    override func viewDidLoad() {
        viewModel = KTAddressPickerViewModel(del:self)
        super.viewDidLoad()
        
        
    }

}
