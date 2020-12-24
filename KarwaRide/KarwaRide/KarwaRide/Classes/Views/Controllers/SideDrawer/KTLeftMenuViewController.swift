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
        //cell.sideView.backgroundColor = (viewModel as! KTLeftMenuModel).colorInCell(idx: indexPath.row)

        cell.lblNew.isHidden = (!(viewModel as! KTLeftMenuModel).isNew(idx: indexPath.row))

        if(Device.getLanguage() == "AR")
        {
            cell.lblNew.image = UIImage(named: "new_tag_ar")!
        }

        cell.lblWarning.isHidden = (viewModel as! KTLeftMenuModel).isEmailVerified(idx: indexPath.row)

        return cell
     }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        // Temporary removing the highlighting of left menus
        if(indexPath.row != 3 && indexPath.row != 4)
        {
            if lastSelectedCell != nil {
                lastSelectedCell?.sideView.isHidden = true
              lastSelectedCell?.contentView.backgroundColor = UIColor.white
              lastSelectedCell?.lblTitle.font = UIFont.H4().regular
              // reset cell styling
            }

            let cell : LeftMenuTableViewCell = tableView.cellForRow(at: indexPath) as! LeftMenuTableViewCell
          cell.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            cell.lblTitle.font = UIFont.H4().bold
            //cell.sideView.isHidden = false
          // do cell styling

            lastSelectedCell = cell
        }

        switch indexPath.row {
        case 0:
            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
            sideMenuController?.hideMenu()
            break

        case 1:
            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyTirpsNavigationController")
            sideMenuController?.hideMenu()
            break

        case 2:
            let contentView : UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "KTFareNavigation") as! UINavigationController
            let detailView : KTFareHTMLViewController = (contentView.viewControllers)[0] as! KTFareHTMLViewController
            detailView.isPromotion = true
            sideMenuController?.contentViewController = contentView
            sideMenuController?.hideMenu()
            break

        case 3:
            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PaymentNavigationController")
//            sideMenuController?.hideMenuViewController()
            break

        case 4:
            let contentView : UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "KTFareNavigation") as! UINavigationController
            let detailView : KTFareHTMLViewController = (contentView.viewControllers)[0] as! KTFareHTMLViewController
            detailView.isFeedback = true
            sideMenuController?.contentViewController = contentView
            sideMenuController?.hideMenu()
            break

        case 5:
            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationNavigationController")
            sideMenuController?.hideMenu()
            break
        
        case 6:
            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "KTFareNavigation")
            sideMenuController?.hideMenu()
            break

        case 7:
            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsNavigationController")
            sideMenuController?.hideMenu()
            break

        default:
            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "UnderConstructionNavigationController")
            sideMenuController?.hideMenu()
            break
        }

        return false
    }
}
