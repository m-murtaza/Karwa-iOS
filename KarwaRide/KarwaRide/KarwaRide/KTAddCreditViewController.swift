//
//  KTAddCreditViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 07/04/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class KTAddCreditViewController: KTBaseDrawerRootViewController,UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var creditTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var addCreditTitleLbl: UILabel!
    
    private var vModel : KTWalletViewModel?
    
    private let refreshControl = UIRefreshControl()
    
    var cardArray = ["String","String","String","String"]
    
    override func viewDidLoad() {
        
        if viewModel == nil {
            viewModel = KTWalletViewModel(del: self)
        }
        vModel = viewModel as? KTWalletViewModel
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor(hexString:"#006170"),
                                                                   NSAttributedStringKey.font : UIFont.init(name: "MuseoSans-900", size: 17)!]
        
        addMenuButton()
        
    }
    
    
    @objc func refresh(sender:AnyObject) {
        //        (viewModel as! KTWalletViewModel).fetchBookings()
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 110.0
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let keyLbl = LocalisableLabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        keyLbl.localisedKey = section == 0 ? "cards".localized() : "str_transactions".localized()
        keyLbl.textAlignment = .right
        keyLbl.textColor = UIColor(hexString: "#00A8A8")
        keyLbl.font = UIFont(name: "MuseoSans-500", size: 12.0)!
        
        if Device.language().contains("ar") {
            keyLbl.textAlignment = .right
        } else {
            keyLbl.textAlignment = .left
        }
        
        let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        view.addSubview(keyLbl)
        
        [keyLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
         keyLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
         keyLbl.centerYAnchor.constraint(equalTo: view.centerYAnchor)].forEach({$0.isActive = true})
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let conitnueButton = UIButton()
        conitnueButton.translatesAutoresizingMaskIntoConstraints = false
        conitnueButton.setTitle("txt_continue".localized(), for: .normal)
        
        conitnueButton.setTitleColor( UIColor.white, for: .normal)
        conitnueButton.setBackgroundColor(color: UIColor(hex: "#00A8A8"), forState: .normal)
        conitnueButton.titleLabel?.font = UIFont(name: "MuseoSans-500", size: 12.0)!
        conitnueButton.cornerRadius = 20
        conitnueButton.clipsToBounds = true
        conitnueButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        
        let buttonBgView : UIView = UIView(frame: CGRect(x: 0, y: 1, width: tableView.frame.width, height: 100))
        buttonBgView.backgroundColor = .white
        
        view.addSubview(buttonBgView)
        buttonBgView.addSubview(conitnueButton)
        
        [conitnueButton.heightAnchor.constraint(equalToConstant: 40),
         conitnueButton.widthAnchor.constraint(equalToConstant: 150),
         conitnueButton.centerXAnchor.constraint(equalTo: buttonBgView.centerXAnchor),
         conitnueButton.centerYAnchor.constraint(equalTo: buttonBgView.centerYAnchor)].forEach({$0.isActive = true})
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cardArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : KTWalletTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewCellIdentifier") as! KTWalletTableViewCell
        
        let backgroundCell : KTWalletTableViewBackgroundCell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewBackgroundCellIdentifier") as! KTWalletTableViewBackgroundCell
        backgroundCell.iconImageView.image = #imageLiteral(resourceName: "card_icon")
        
        
        //    cell.cashIcon.isHidden = (viewModel as! KTMyTripsViewModel).showCashIcon(forIdx: indexPath.row)
        //    cell.cashIcon.image = UIImage(named: (viewModel as! KTMyTripsViewModel).getPaymentIcon(forIdx: indexPath.row))
        
        animateCell(cell)
        
        return self.cardArray.count == 0 ? backgroundCell : cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        (viewModel as! KTMyTripsViewModel).rowSelected(forIdx: indexPath.row)
    }
    
    func setBooking(booking : KTBooking) {
        if viewModel == nil {
            viewModel = KTMyTripsViewModel(del: self)
        }
        (viewModel as! KTMyTripsViewModel).selectedBooking = booking
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
    
    func moveToAddCreditCard() {
        
        let addCreditViewController = self.storyboard?.instantiateViewController(withIdentifier: "KTAddCreditViewController") as! KTAddCreditViewController
        
        navigationItem.backButtonTitle = ""
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString:"#E5F5F2")
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor(hexString:"#006170"),
                                                                        NSAttributedStringKey.font : UIFont.init(name: "MuseoSans-900", size: 17)!]
        
        self.navigationController?.pushViewController(addCreditViewController, animated: true)
        
    }
    
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    //MARK:- Book Now
    func showNoBooking() {
        tableView.isHidden = true
    }
    
    @IBAction func bookNowTapped(){
        sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
        sideMenuController?.hideMenu()
    }
    
}
