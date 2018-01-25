//
//  KTAddressPickerViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/23/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTAddressPickerViewController: KTBaseViewController,KTAddressPickerViewModelDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        viewModel = KTAddressPickerViewModel(del:self)
        super.viewDidLoad()
    }
    
    // MARK: - View Model Delegate
    func loadData() {
        tblView.reloadData()
    }
    
    // MARK: - TableView Daligates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTAddressPickerViewModel).numberOfRow()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "AddPickCellIdentifier")
        
        let lblAddress  : UILabel = cell.contentView.viewWithTag(1001) as! UILabel
        lblAddress.text = "abcd"
        
        return cell
    }
    
}


