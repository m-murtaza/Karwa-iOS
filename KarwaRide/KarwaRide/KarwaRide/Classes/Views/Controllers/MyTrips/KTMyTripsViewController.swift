//
//  KTMyTripsViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/26/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTMyTripsViewController: KTBaseDrawerRootViewController,KTMyTripsViewModelDelegate,UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noBookingView: UIView!
    
    override func viewDidLoad() {
        self.viewModel = KTMyTripsViewModel(del: self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        return (viewModel as! KTMyTripsViewModel).numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //MyTripsReuseIdentifier
        let cell : KTMyTripsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyTripsReuseIdentifier") as! KTMyTripsTableViewCell
        
        cell.lblPickAddress.text = (viewModel as! KTMyTripsViewModel).pickAddress(forIdx: indexPath.row)
        cell.lblDropoffAddress.text = (viewModel as! KTMyTripsViewModel).dropAddress(forIdx: indexPath.row)
        
        cell.lblDayOfMonth.text = (viewModel as! KTMyTripsViewModel).pickupDateOfMonth(forIdx: indexPath.row)
        
        cell.lblMonth.text = (viewModel as! KTMyTripsViewModel).pickupMonth(forIdx: indexPath.row)
        cell.lblYear.text = (viewModel as! KTMyTripsViewModel).pickupYear(forIdx: indexPath.row)
        
        cell.lblDayAndTime.text = (viewModel as! KTMyTripsViewModel).pickupDayAndTime(forIdx: indexPath.row)
        
        cell.lblServiceType.text = (viewModel as! KTMyTripsViewModel).vehicleType(forIdx: indexPath.row)
        
        let img : UIImage? = (viewModel as! KTMyTripsViewModel).bookingStatusImage(forIdx: indexPath.row)
        if img != nil {
            cell.imgBookingStatus.image = img
        }
        
        if isLargeScreen()  && (viewModel as! KTMyTripsViewModel).showCallerID(){
            cell.lblCallerId.isHidden = false
            cell.lblCallerId.text = (viewModel as! KTMyTripsViewModel).callerId(forIdx: indexPath.row)
        }
        
        
        cell.viewCard.backgroundColor = (viewModel as! KTMyTripsViewModel).cellBGColor(forIdx: indexPath.row)
        
        cell.viewCard.borderColor = (viewModel as! KTMyTripsViewModel).cellBorderColor(forIdx: indexPath.row)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        (viewModel as! KTMyTripsViewModel).rowSelected(forIdx: indexPath.row)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueMyTripsToDetails" {
            
            let details : KTBookingDetailsViewController  = segue.destination as! KTBookingDetailsViewController
            if let booking : KTBooking = (viewModel as! KTMyTripsViewModel).selectedBooking {
                details.setBooking(booking: booking)
            }
        }
    }
    
    func moveToDetails() {
        self.performSegue(name: "segueMyTripsToDetails")
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
        
        sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
        sideMenuViewController?.hideMenuViewController()
    }

}
