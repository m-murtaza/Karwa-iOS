//
//  KSSideDrawerTableView.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/22/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import BarcodeScanner
import SideMenuSwift

var lastSelectedIndexPath = IndexPath.init(row: 0, section: 0)
enum NotifySideMenu {
    case rebook
    case bookingDetail
    case none
}

class KTLeftMenuViewController: KTBaseViewController, UITableViewDelegate,UITableViewDataSource,KTLeftMenuDelegate {
    
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblPhone : UILabel!
    @IBOutlet weak var tableView: UITableView!

    var DrawerOption = [String]()
    var lastSelectedCell:LeftMenuTableViewCell?
    
    var notifySideMenu: NotifySideMenu = .none
    var bookingData: KTBooking?
    
    override func viewDidLoad() {
        
        //view.backgroundColor = UIColor.clear
        viewModel = KTLeftMenuModel(del:self)
        super.viewDidLoad()
        self.setupSideMenu()
     
        self.setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: (#selector(updateUI)), name:NSNotification.Name(rawValue: "TimeToUpdateTheUINotificaiton"), object: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "NotifySideMenu"), object: nil, queue: .main) { [weak self] (notification) in
            guard let `self` = self else { return }
            if let notify = notification.userInfo?["Notify"] as? NotifySideMenu {
                self.notifySideMenu = notify
                switch notify {
                case .rebook, .bookingDetail:
                    if let data = notification.userInfo?["Data"] as? KTBooking {
                        self.bookingData = data
                    }
                case .none:
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        (viewModel as! KTLeftMenuModel).reloadData()

    }
    
    @objc func updateUI()
    {
        (viewModel as! KTLeftMenuModel).reloadData()
//        showSuccessBanner("", "Profile Updated")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupSideMenu() {
        sideMenuController?.cache(viewControllerGenerator: {
            self.getVC(storyboard: .MAIN, vcIdentifier: "BookingNavigationViewController")
        }, with: "0")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.getVC(storyboard: .MAIN, vcIdentifier: "MyTirpsNavigationController")
        }, with: "1")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.getVC(storyboard: .MAIN, vcIdentifier: "KTWalletNavigationController")
        }, with: "2")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.getVC(storyboard: .PROMOTIONS, vcIdentifier: "KTPromotionsNavigationController")
        }, with: "3")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.getVC(storyboard: .MAIN, vcIdentifier: "PaymentNavigationController")
        }, with: "4")
        
        sideMenuController?.cache(viewControllerGenerator: {
            let contentView : UINavigationController = self.getVC(storyboard: .MAIN, vcIdentifier: "KTFareNavigation") as! UINavigationController
            let detailView : KTFareHTMLViewController = (contentView.viewControllers)[0] as! KTFareHTMLViewController
            detailView.isFeedback = true
            return contentView
        }, with: "5")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.getVC(storyboard: .MAIN, vcIdentifier: "NotificationNavigationController")
        }, with: "6")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.getVC(storyboard: .MAIN, vcIdentifier: "KTFareNavigation")
        }, with: "7")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.getVC(storyboard: .MAIN, vcIdentifier: "SettingsNavigationController")
        }, with: "8")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.getVC(storyboard: .MAIN, vcIdentifier: "UnderConstructionNavigationController")
        }, with: "9")
        
        sideMenuController?.delegate = self
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
         
         if indexPath == lastSelectedIndexPath {
             cell.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
             cell.lblTitle.font = UIFont.H4().bold
         } else {
             cell.contentView.backgroundColor = UIColor.clear//lightGray.withAlphaComponent(0.2)
             cell.lblTitle.font = UIFont.H4().regular
         }
                  
     // Configure the cell...
        cell.lblTitle.text = (viewModel as! KTLeftMenuModel).textInCell(idx: indexPath.row)
        cell.lblTitle.textColor = (viewModel as! KTLeftMenuModel).colorInCell(idx: indexPath.row)
        cell.imgTypeIcon.image = (viewModel as! KTLeftMenuModel).ImgTypeInCell(idx: indexPath.row)
        //cell.sideView.backgroundColor = (viewModel as! KTLeftMenuModel).colorInCell(idx: indexPath.row)

        cell.lblNew.isHidden = (!(viewModel as! KTLeftMenuModel).isNew(idx: indexPath.row))
        
        if (KTPaymentManager().getAllPayments().filter({$0.payment_type == "WALLET"}).first?.balance ?? "").count > 0 {
            cell.walletAmountLbl.isHidden = (!(viewModel as! KTLeftMenuModel).isNew(idx: indexPath.row))
            cell.walletAmountLbl.text =  (KTPaymentManager().getAllPayments().filter({$0.payment_type == "WALLET"}).first?.balance ?? "") + "  "
            cell.lblNew.isHidden = true
        } else {
            cell.walletAmountLbl.isHidden = true
        }
        
        cell.walletAmountLbl.layer.cornerRadius = 5
        cell.walletAmountLbl.layer.masksToBounds = true
        
        if(Device.getLanguage() == "AR")
        {
            cell.lblNew.image = UIImage(named: "new_tag_ar")!
        }

        cell.lblWarning.isHidden = (viewModel as! KTLeftMenuModel).isEmailVerified(idx: indexPath.row)

        return cell
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        // Temporary removing the highlighting of left menus
//        if(indexPath.row != 3 && indexPath.row != 4)
//        {
////            if lastSelectedCell != nil {
////                lastSelectedCell?.sideView.isHidden = true
////              lastSelectedCell?.contentView.backgroundColor = UIColor.white
////              lastSelectedCell?.lblTitle.font = UIFont.H4().regular
////              // reset cell styling
////            }
        ///
        
//
//        KTUserManager().fetchVersion()
        if(indexPath.row != 4) {
            lastSelectedIndexPath  = indexPath
        } else {
            lastSelectedIndexPath = IndexPath.init(row: 0, section: 0)
        }

        if indexPath.row == 0 {
            xpressRebookSelected = false
        }
        sideMenuController?.setContentViewController(with: "\(indexPath.row)", animated: true)
        sideMenuController?.hideMenu()
    }
    
//    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//
//        // Temporary removing the highlighting of left menus
//        if(indexPath.row != 3 && indexPath.row != 4)
//        {
//
//        }
//
//        if lastSelectedCell != nil {
//            lastSelectedCell?.sideView.isHidden = true
//          lastSelectedCell?.contentView.backgroundColor = UIColor.white
//          lastSelectedCell?.lblTitle.font = UIFont.H4().regular
//          // reset cell styling
//        }
//
//        let cell : LeftMenuTableViewCell = tableView.cellForRow(at: indexPath) as! LeftMenuTableViewCell
//        cell.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
//        cell.lblTitle.font = UIFont.H4().bold
//        //cell.sideView.isHidden = false
//      // do cell styling
//
//        //lastSelectedCell = cell
//
//        switch indexPath.row {
//        case 0:
//            xpressRebookSelected = false
//            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
//            sideMenuController?.hideMenu()
//            break
//
//        case 1:
//            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyTirpsNavigationController")
//            sideMenuController?.hideMenu()
//            break
//
//        case 2:
//            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "KTWalletNavigationController")
//            sideMenuController?.hideMenu()
//            break
//
//        case 3:
//            let contentView : UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "KTFareNavigation") as! UINavigationController
//            let detailView : KTFareHTMLViewController = (contentView.viewControllers)[0] as! KTFareHTMLViewController
//            detailView.isPromotion = true
//            sideMenuController?.contentViewController = contentView
//            sideMenuController?.hideMenu()
//            break
//
//        case 4:
//            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PaymentNavigationController")
//            sideMenuController?.hideMenu()
//            break
//
//        case 5:
//            let contentView : UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "KTFareNavigation") as! UINavigationController
//            let detailView : KTFareHTMLViewController = (contentView.viewControllers)[0] as! KTFareHTMLViewController
//            detailView.isFeedback = true
//            sideMenuController?.contentViewController = contentView
//            sideMenuController?.hideMenu()
//            break
//
//        case 6:
//            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationNavigationController")
//            sideMenuController?.hideMenu()
//            break
//
//        case 7:
//            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "KTFareNavigation")
//            sideMenuController?.hideMenu()
//            break
//
//        case 8:
//            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsNavigationController")
//            sideMenuController?.hideMenu()
//            break
//
//        default:
//            sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "UnderConstructionNavigationController")
//            sideMenuController?.hideMenu()
//            break
//        }
//
//        return false
//    }
}

extension UILabel {
    func setMargins(_ margin: CGFloat = 10) {
        if let textString = self.text {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = margin
            paragraphStyle.headIndent = margin
            paragraphStyle.tailIndent = margin
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
}

extension KTLeftMenuViewController: SideMenuControllerDelegate {
    func sideMenuController(_ sideMenuController: SideMenuController,
                            animationControllerFrom fromVC: UIViewController,
                            to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BasicTransitionAnimator(options: .transitionCrossDissolve, duration: 0.6)
    }
    
    func sideMenuController(_ sideMenuController: SideMenuController, willShow viewController: UIViewController, animated: Bool) {
        if let navVC : UINavigationController = viewController as? UINavigationController {
            if let tabController = navVC.topViewController as? TabViewController, self.notifySideMenu == .rebook {
                self.notifySideMenu = .none
                let createBooking : KTCreateBookingViewController = tabController.viewControllers![0] as! KTCreateBookingViewController
                createBooking.booking = self.bookingData
                createBooking.setRemoveBookingOnReset(removeBookingOnReset: false)
                createBooking.rebookNavigation()
                self.bookingData = nil
            }
            else if let destinationVC = navVC.topViewController as? KTMyTripsViewController, self.notifySideMenu == .bookingDetail {
                self.notifySideMenu = .none
                if let data = self.bookingData {
                    destinationVC.setBooking(booking: data)
                    self.bookingData = nil
                }
            }
        }
    }
}
