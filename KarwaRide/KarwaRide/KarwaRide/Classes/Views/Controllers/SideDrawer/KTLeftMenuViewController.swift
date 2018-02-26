//
//  KSSideDrawerTableView.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/22/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit

class KTLeftMenuViewController: KTBaseViewController, UITableViewDelegate,UITableViewDataSource {
    
    var DrawerOption = [String]()
    var lastSelectedCell:LeftMenuTableViewCell?
    override func viewDidLoad() {
        
        //view.backgroundColor = UIColor.clear
        viewModel = KTLeftMenuModel(del:self)
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (viewModel as! KTLeftMenuModel).numberOfRowsInSection()
    }


     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LeftMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SideDrawerCell", for: indexPath) as! LeftMenuTableViewCell
     
     // Configure the cell...
        cell.lblTitle.text = (viewModel as! KTLeftMenuModel).textInCell(idx: indexPath.row)
        cell.lblTitle.textColor = (viewModel as! KTLeftMenuModel).colorInCell(idx: indexPath.row)
        cell.imgTypeIcon.image = (viewModel as! KTLeftMenuModel).ImgTypeInCell(idx: indexPath.row)
        cell.sideView.backgroundColor = (viewModel as! KTLeftMenuModel).colorInCell(idx: indexPath.row)
        
        cell.selectedBackgroundView = UIView()
     
        return cell
     }
    
    func tableView(_ tableView: UITableView,
                   shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        if lastSelectedCell != nil {
            
            lastSelectedCell?.sideView.isHidden = true
            lastSelectedCell?.imgSelected.isHidden = true
        }
        
        let cell : LeftMenuTableViewCell = tableView.cellForRow(at: indexPath) as! LeftMenuTableViewCell
                cell.sideView.isHidden = false
                cell.imgSelected.isHidden = false
        
        lastSelectedCell = cell
        return false
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//       // self.performSegue(withIdentifier: (viewModel as! KTLeftMenuModel).segueIdentifireForIdxPath(idx: indexPath.row), sender: self)
//        let cell : LeftMenuTableViewCell = tableView.cellForRow(at: indexPath) as! LeftMenuTableViewCell
//        cell.sideView.isHidden = false
//        cell.imgSelected.isHidden = false
//    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell : LeftMenuTableViewCell = tableView.cellForRow(at: indexPath) as! LeftMenuTableViewCell
//                cell.sideView.isHidden = true
//                cell.imgSelected.isHidden = true
//    }
//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        let cell : LeftMenuTableViewCell = tableView.cellForRow(at: indexPath) as! LeftMenuTableViewCell
//        cell.sideView.isHidden = false
//        cell.imgSelected.isHidden = false
//        return indexPath
//    }
//
//    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
//        let cell : LeftMenuTableViewCell = tableView.cellForRow(at: indexPath) as! LeftMenuTableViewCell
//        cell.sideView.isHidden = true
//        cell.imgSelected.isHidden = true
//        return indexPath
//    }
}
