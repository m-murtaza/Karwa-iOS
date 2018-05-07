//
//  KTNotificationViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/30/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTNotificationViewController: KTBaseDrawerRootViewController,KTNotificationViewModelDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tblView : UITableView!
    
    private var vModel : KTNotificationViewModel?
    override func viewDidLoad() {
        self.viewModel = KTNotificationViewModel(del: self)
        vModel = viewModel as? KTNotificationViewModel
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueNotificationToDetail" {
            let details : KTBookingDetailsViewController  = segue.destination as! KTBookingDetailsViewController
            if let booking : KTBooking = vModel?.selectedBooking {
                details.setBooking(booking: booking)
            }
        }
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (vModel?.numberOfRows())!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : KTNotificationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCellIdentifier") as! KTNotificationTableViewCell
        cell.lblMessage.text = vModel?.message(forCellIdx: indexPath.row)
        cell.lbldateTime.text = vModel?.dateTime(forCellIdx: indexPath.row)
        cell.lblAgoTime.text = vModel?.agoTime(forCellIdx: indexPath.row)
        cell.imgIcon.image = vModel?.notificationIcon(forCellIdx: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return UIView(frame:
            CGRect(x: 0, y: 0, width: 10 , height: 30))
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vModel?.rowSelected(atIndex: indexPath.row)
    }
    
    func reloadTableData()  {
        tblView.reloadData()
    }
    
    func showDetail() {
        
        self.performSegue(name: "segueNotificationToDetail")
    }
}

