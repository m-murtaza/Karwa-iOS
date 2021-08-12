//
//  KTXpressMyTripsViewController.swift
//  KarwaRide
//
//  Created by Satheesh on 8/8/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

class KTXpressMyTripsViewController: KTBaseDrawerRootViewController,KTMyTripsViewModelDelegate,UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noBookingView: UIView!
    
    private var vModel : KTXpressMyTripsViewModel?

    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        if viewModel == nil
        {
            viewModel = KTXpressMyTripsViewModel(del: self)
        }
        vModel = viewModel as? KTXpressMyTripsViewModel
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor(hexString:"#006170"),
                                                                   NSAttributedStringKey.font : UIFont.init(name: "MuseoSans-900", size: 17)!]

//        if #available(iOS 13.0, *) {
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//            UINavigationBar.init().scrollEdgeAppearance = appearance
//        } else {
//            // Fallback on earlier versions
//        }
        
      addMenuButton()
    }

    override func updateForBooking(_ booking: KTBooking)
    {
        vModel?.bookingUpdateTriggered(booking)
    }
    
    @objc func refresh(sender:AnyObject)
    {
        (viewModel as! KTXpressMyTripsViewModel).fetchBookings()
    }
    
    func endRefreshing()
    {
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 148.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTXpressMyTripsViewModel).numberOfRows()
    }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //MyTripsReuseIdentifier
    let cell : KTMyTripsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyTripsReuseIdentifier") as! KTMyTripsTableViewCell
    
    cell.pickupAddressLabel.text = (viewModel as! KTXpressMyTripsViewModel).pickAddress(forIdx: indexPath.row)
    cell.dropoffAddressLabel.text = (viewModel as! KTXpressMyTripsViewModel).dropAddress(forIdx: indexPath.row)
    cell.dateLabel.text = (viewModel as! KTXpressMyTripsViewModel).pickupDate(forIdx: indexPath.row)
    cell.timeLabel.text = (viewModel as! KTXpressMyTripsViewModel).pickupDayAndTime(forIdx: indexPath.row)
    cell.serviceTypeLabel.text = (viewModel as! KTXpressMyTripsViewModel).vehicleType(forIdx: indexPath.row)
    cell.statusLabel.text = (viewModel as! KTXpressMyTripsViewModel).bookingStatusString(forIdx: indexPath.row)
    cell.outerContainer.backgroundColor = (viewModel as! KTXpressMyTripsViewModel).outerContainerBackgroundColor(forIdx: indexPath.row)
    cell.innerContainer.backgroundColor = (viewModel as! KTXpressMyTripsViewModel).innerContainerBackgroundColor(forIdx: indexPath.row)
    cell.statusLabel.textColor = (viewModel as! KTXpressMyTripsViewModel).statusTextColor(forIdx: indexPath.row)
    cell.capacityLabel.text = (viewModel as! KTXpressMyTripsViewModel).capacity(forIdx: indexPath.row)
    cell.serviceTypeLabel.textColor = (viewModel as! KTXpressMyTripsViewModel).serviceTypeColor(forIdx: indexPath.row)
    cell.cashIcon.isHidden = (viewModel as! KTXpressMyTripsViewModel).showCashIcon(forIdx: indexPath.row)
    cell.cashIcon.image = UIImage(named: (viewModel as! KTXpressMyTripsViewModel).getPaymentIcon(forIdx: indexPath.row))
    
    if (viewModel as! KTXpressMyTripsViewModel).cancellationCharge(forIdx: indexPath.row) != "" {
        cell.cancellationChargeLabel.text = (viewModel as! KTXpressMyTripsViewModel).cancellationCharge(forIdx: indexPath.row)
        cell.cancellationChargeLabel.isHidden = false
        if Device.getLanguage().contains("AR") {
            cell.cancellationChargeLabel.textAlignment = .left
        } else {
            cell.cancellationChargeLabel.textAlignment = .right
        }
    } else {
        cell.cancellationChargeLabel.isHidden = true
    }
    
    cell.detailArrow.image?.imageFlippedForRightToLeftLayoutDirection()
    //        if isLargeScreen()  && (viewModel as! KTXpressMyTripsViewModel).showCallerID(){
    //            cell.lblCallerId.isHidden = false
    //            cell.lblCallerId.text = (viewModel as! KTXpressMyTripsViewModel).callerId(forIdx: indexPath.row)
    //        }
    animateCell(cell)
    
    return cell
  }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        (viewModel as! KTXpressMyTripsViewModel).rowSelected(forIdx: indexPath.row)
    }
    
    func setBooking(booking : KTBooking) {
        if viewModel == nil {
            viewModel = KTXpressMyTripsViewModel(del: self)
        }
        (viewModel as! KTXpressMyTripsViewModel).selectedBooking = booking
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueMyTripsToDetails" {
            
            let details : KTBookingDetailsViewController  = segue.destination as! KTBookingDetailsViewController
            if let booking : KTBooking = (viewModel as! KTXpressMyTripsViewModel).selectedBooking {
                details.setBooking(booking: booking)
            }
        }
    }
    
    func moveToDetails() {
        
        let bookingDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "KTXpressBookingDetailsViewController") as! KTXpressBookingDetailsViewController

        if let booking : KTBooking = (viewModel as! KTXpressMyTripsViewModel).selectedBooking {
            bookingDetailsViewController.setBooking(booking: booking)
            (viewModel as! KTXpressMyTripsViewModel).selectedBooking = nil;
        }
        
        navigationItem.backButtonTitle = ""
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString:"#E5F5F2")
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor(hexString:"#006170"),
             NSAttributedStringKey.font : UIFont.init(name: "MuseoSans-900", size: 17)!]
        
        self.navigationController?.pushViewController(bookingDetailsViewController, animated: true)
        
        
        //self.performSegue(name: "segueMyTripsToDetails")
    }
    
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    //MARK:- Book Now
    func showNoBooking() {
        
        tableView.isHidden = true
        noBookingView.isHidden = false
    }
    @IBAction func bookNowTapped(){
        
      sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
        sideMenuController?.hideMenu()
    }

}
