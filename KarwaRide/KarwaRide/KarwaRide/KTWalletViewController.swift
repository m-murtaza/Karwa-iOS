//
//  KTWalletViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 05/04/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

class KTWalletViewController:  KTBaseDrawerRootViewController,UITableViewDataSource, UITableViewDelegate, KTWalletViewModelDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCreditCardButton: UIButton!
    @IBOutlet weak var availableBalanceTitleLable: UILabel!
    @IBOutlet weak var availableBalanceValueLable: UILabel!
    
    private var vModel : KTWalletViewModel?
    
    private let refreshControl = UIRefreshControl()
    
    var cardArray = [String]()
    var transactionArray = ["String","String","String","String"]

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
        
        addCreditCardButton.addTarget(self, action: #selector(moveToAddCreditCard), for: .touchUpInside)
        
        CardIOUtilities.preload()
        
        tableView.tableFooterView = UIView(frame: .zero)
     
        self.tableView.allowsMultipleSelectionDuringEditing = false

    }
    
    
    @objc func refresh(sender:AnyObject) {
        (viewModel as! KTWalletViewModel).fetchTransactions()
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func loadAvailableBalance(_ amount: String) {
        self.availableBalanceValueLable.text = amount
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
        
        if indexPath.section == 0 {
            return (self.viewModel as! KTWalletViewModel).paymentMethods.count == 0 ? 110.0 : 70.0
        } else {
            return (self.viewModel as! KTWalletViewModel).transactions.count == 0 ? 110.0 : 70.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let keyLbl = LocalisableLabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        keyLbl.localisedKey = section == 0 ? "cards".localized() : "str_transactions".localized()
        keyLbl.textAlignment = .right
        keyLbl.textColor = UIColor(hexString: "#00A8A8")
        keyLbl.font = UIFont(name: "MuseoSans-500", size: 12.0)!
        
        let valueLbl = UIButton()
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        valueLbl.setTitle(section == 0 ? "txt_manage_lc".localized() : "", for: .normal)
        
        if Device.language().contains("ar") {
            valueLbl.titleLabel?.textAlignment = .left
            keyLbl.textAlignment = .right
        } else {
            keyLbl.textAlignment = .left
            valueLbl.titleLabel?.textAlignment = .right
        }
        
        valueLbl.setTitleColor( UIColor(hexString: "#129793"), for: .normal)
        valueLbl.titleLabel?.font = UIFont(name: "MuseoSans-500", size: 12.0)!
        
        let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let stackView = UIStackView(arrangedSubviews: [keyLbl, valueLbl])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        
        view.addSubview(stackView)
        
        [stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
         stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
         stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)].forEach({$0.isActive = true})
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 150 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let addCardButton = UIButton()
        addCardButton.translatesAutoresizingMaskIntoConstraints = false
        addCardButton.setTitle("str_add_card".localized(), for: .normal)
        
        addCardButton.setTitleColor( UIColor.white, for: .normal)
        addCardButton.setBackgroundColor(color: UIColor(hex: "#00A8A8"), forState: .normal)
        addCardButton.titleLabel?.font = UIFont(name: "MuseoSans-500", size: 12.0)!
        addCardButton.setImage(#imageLiteral(resourceName: "card_ico_btn"), for: .normal)
        addCardButton.cornerRadius = 20
        addCardButton.clipsToBounds = true
        addCardButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        let keyLbl = LocalisableLabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        keyLbl.localisedKey = section == 0 ? "str_seamless".localized() : ""
        keyLbl.textAlignment = .right
        keyLbl.textColor = UIColor(hexString: "#B4B4B4")
        keyLbl.font = UIFont(name: "MuseoSans-500", size: 12.0)!
        
        let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 130))
    
        let seperatorView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        seperatorView.backgroundColor = UIColor(hexString: "#B4B4B4")

        let buttonBgView : UIView = UIView(frame: CGRect(x: 0, y: 1, width: tableView.frame.width, height: 100))
        buttonBgView.backgroundColor = .white
        
        view.addSubview(seperatorView)
        view.addSubview(buttonBgView)
        buttonBgView.addSubview(addCardButton)
        view.addSubview(keyLbl)

        
        [addCardButton.heightAnchor.constraint(equalToConstant: 40),
         addCardButton.widthAnchor.constraint(equalToConstant: 150),
        addCardButton.centerXAnchor.constraint(equalTo: buttonBgView.centerXAnchor),
        addCardButton.centerYAnchor.constraint(equalTo: buttonBgView.centerYAnchor)].forEach({$0.isActive = true})

        [keyLbl.heightAnchor.constraint(equalToConstant: 40),
         keyLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
         keyLbl.topAnchor.constraint(equalTo: buttonBgView.bottomAnchor, constant: 20)].forEach({$0.isActive = true})
        
        return section == 0 ? view : nil
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return (self.viewModel as! KTWalletViewModel).numberOfCardRows()
        } else {
            return (self.viewModel as! KTWalletViewModel).numberOfTransactionRows()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //MyTripsReuseIdentifier
        
        
        if indexPath.section == 0 {
            
            if (self.viewModel as! KTWalletViewModel).paymentMethods.count == 0 {
                let backgroundCell : KTWalletTableViewBackgroundCell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewBackgroundCellIdentifier") as! KTWalletTableViewBackgroundCell
                backgroundCell.iconImageView.image = #imageLiteral(resourceName: "card_icon")
                return backgroundCell
            }
                        
            let cell : KTWalletTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewCellIdentifier") as! KTWalletTableViewCell
            cell.titleLabel.text = vModel?.paymentMethodName(forCellIdx: indexPath.row)
            cell.detailLable.text = vModel?.expiry(forCellIdx: indexPath.row)
            cell.iconImageView.image  = vModel?.cardIcon(forCellIdx: indexPath.row)
            cell.selectionStyle = .none

            cell.descriptionLabel.isHidden = true

           
            return cell

        } else  if indexPath.section == 1 {
            
            if (self.viewModel as! KTWalletViewModel).transactions.count != 0 {
                
                let cell : KTWalletTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCellIdentifier") as! KTWalletTableViewCell
                cell.titleLabel.text = ""
                cell.titleLabel.attributedText = vModel?.titelLabel(forCellIdx: indexPath.row)
                cell.descriptionLabel.text = vModel?.descriptionLabel(forCellIdx: indexPath.row)
                cell.detailLable.text = ""
                cell.detailLable.attributedText = vModel?.detailLabel(forCellIdx: indexPath.row)
                cell.iconImageView.image = vModel?.transactionIcon(forCellIdx: indexPath.row)
                cell.descriptionLabel.textColor = UIColor(hexString: "#B4B4B4")
                return cell
                
            } else {
                let backgroundCell : KTWalletTableViewBackgroundCell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewBackgroundCellIdentifier") as! KTWalletTableViewBackgroundCell
                backgroundCell.iconImageView.image = #imageLiteral(resourceName: "empty_trans_icon")
                return backgroundCell
            }
                         
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    @objc func moveToAddCreditCard() {
        
        let addCreditViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddCreditViewController") as! KTAddCreditViewController
        
        self.navigationController?.present(addCreditViewController, animated: true, completion: nil)
                
    }
    
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    //MARK:- Book Now
    func showNoBooking() {
        tableView.isHidden = true
        //        noBookingView.isHidden = false
    }
    
    @IBAction func bookNowTapped(){
        sideMenuController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
        sideMenuController?.hideMenu()
    }
    
    func reloadTableData() {
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
}


class KTWalletTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var detailLable : UILabel!
    @IBOutlet weak var iconImageView : UIImageView!
    @IBOutlet weak var selectedIconImageView : UIImageView!
    @IBOutlet weak var selectedView : UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class KTWalletTableViewBackgroundCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var iconImageView : UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


