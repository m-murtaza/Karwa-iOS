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
    
    override func viewDidLoad() {
        viewModel = KTSideDrawerModel(del:self)
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (viewModel as! KTSideDrawerModel).numberOfRowsInSection()
    }


     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideDrawerCell", for: indexPath) as UITableViewCell
     
     // Configure the cell...
        cell.textLabel?.text = (viewModel as! KTSideDrawerModel).textInCell(idx: indexPath.row)
     
        return cell
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: (viewModel as! KTSideDrawerModel).segueIdentifireForIdxPath(idx: indexPath.row), sender: self)
    }
}
