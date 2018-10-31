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
    
    var DrawerOption = [String]()
    var lastSelectedCell:LeftMenuTableViewCell?
    override func viewDidLoad() {
        
        //view.backgroundColor = UIColor.clear
        viewModel = KTLeftMenuModel(del:self)
        super.viewDidLoad()
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
        
        cell.selectedBackgroundView = UIView()
     
        return cell
     }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        if(indexPath.row != 4)
        {
            if lastSelectedCell != nil {
                
                lastSelectedCell?.sideView.isHidden = true
                lastSelectedCell?.imgSelected.isHidden = true
            }
            
            let cell : LeftMenuTableViewCell = tableView.cellForRow(at: indexPath) as! LeftMenuTableViewCell
            cell.sideView.isHidden = false
            cell.imgSelected.isHidden = false
            
            lastSelectedCell = cell
        }

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
//          presentBarcodeScanner()
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
        
        return false
    }
    
    private func presentPaymentViewController()
    {
//        present(makePaymentViewController(), animated: true, completion: nil)
        UIApplication.topViewController()?.present(makePaymentViewController(), animated: true, completion: nil)
    }
    
    private func makePaymentViewController() -> KTPaymentViewController
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "KTPaymentViewControllerIdentifier") as! KTPaymentViewController
        
        return viewController
    }
}

extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}
