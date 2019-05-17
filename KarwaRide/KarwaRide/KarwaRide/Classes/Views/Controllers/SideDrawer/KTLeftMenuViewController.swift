//
//  KSSideDrawerTableView.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/22/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import BarcodeScanner

class KTLeftMenuViewController: KTBaseViewController, UITableViewDelegate,UITableViewDataSource,KTLeftMenuDelegate {
    
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblPhone : UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var DrawerOption = [String]()
    var lastSelectedCell:LeftMenuTableViewCell?
    override func viewDidLoad() {
        
        //view.backgroundColor = UIColor.clear
        viewModel = KTLeftMenuModel(del:self)
        super.viewDidLoad()
     
        NotificationCenter.default.addObserver(self, selector: (Selector(("updateUI"))), name:NSNotification.Name(rawValue: "TimeToUpdateTheUINotificaiton"), object: nil)
    }
    
    func updateUI()
    {
        (viewModel as! KTLeftMenuModel).reloadData()
//        showSuccessBanner("", "Profile Updated")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadTable()
    {
        tableView.reloadData()
    }
    
    //MARK: - ViewModel Delegate
    func updateUserName (name : String) {
        self.lblName.text = name
    }
    
    func updatePhoneNumber(phone: String) {
        self.lblPhone.text = phone
    }
    //MARK: - TableView DataSource and Delegate
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
        cell.lblNew.isHidden = (!(viewModel as! KTLeftMenuModel).isNew(idx: indexPath.row))
        cell.selectedBackgroundView = UIView()

        cell.lblWarning.isHidden = (viewModel as! KTLeftMenuModel).isEmailVerified(idx: indexPath.row)

        return cell
     }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        // Temporary removing the highlighting of left menus
//        if(indexPath.row != 3 && indexPath.row != 4)
//        {
//            if lastSelectedCell != nil {
//
//                lastSelectedCell?.sideView.isHidden = true
//                lastSelectedCell?.imgSelected.isHidden = true
//            }
//
//            let cell : LeftMenuTableViewCell = tableView.cellForRow(at: indexPath) as! LeftMenuTableViewCell
//            cell.sideView.isHidden = false
//            cell.imgSelected.isHidden = false
//
//            lastSelectedCell = cell
//        }

        /* With scan N pay */
        switch indexPath.row {
        case 0:
            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
            sideMenuViewController?.hideMenuViewController()
            break
        case 1:

            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyTirpsNavigationController")
            sideMenuViewController?.hideMenuViewController()
            break
        case 2:

            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationNavigationController")
            sideMenuViewController?.hideMenuViewController()
            break
        case 3:
            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "KTFareNavigation")
            sideMenuViewController?.hideMenuViewController()
            break
        case 4:
            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PaymentNavigationController")
            sideMenuViewController?.hideMenuViewController()
            break
        case 5:
            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsNavigationController")
            sideMenuViewController?.hideMenuViewController()
            break

        default:
            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "UnderConstructionNavigationController")
            sideMenuViewController?.hideMenuViewController()
            break
        }
        
        
        
        /* Without scan N pay */
//        switch indexPath.row {
//        case 0:
//            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
//            sideMenuViewController?.hideMenuViewController()
//            break
//        case 1:
//            
//            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyTirpsNavigationController")
//            sideMenuViewController?.hideMenuViewController()
//            break
//        case 2:
//            
//            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationNavigationController")
//            sideMenuViewController?.hideMenuViewController()
//            break
//        case 3:
//            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "KTFareNavigation")
//            sideMenuViewController?.hideMenuViewController()
//            break
//        case 4:
//            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsNavigationController")
//            sideMenuViewController?.hideMenuViewController()
//            break
//            
//        default:
//            sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "UnderConstructionNavigationController")
//            sideMenuViewController?.hideMenuViewController()
//            break
//        }
        return false
    }
}
