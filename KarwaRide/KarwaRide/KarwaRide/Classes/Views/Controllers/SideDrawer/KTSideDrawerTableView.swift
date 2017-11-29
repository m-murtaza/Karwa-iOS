//
//  KSSideDrawerTableView.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/22/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KTSideDrawerTableView: KTBaseTableViewController {
    
    var DrawerOption = [String]()
    let viewModel : KTSideDrawerModel = KTSideDrawerModel(del: self)
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        viewModel.ViewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.numberOfRowsInSection()
    }


     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideDrawerCell", for: indexPath) as UITableViewCell
     
     // Configure the cell...
        cell.textLabel?.text = viewModel.textInCell(idx: indexPath.row)
     
        return cell
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: viewModel.segueIdentifireForIdxPath(idx: indexPath.row), sender: self)
    }
}
