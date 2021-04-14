//
//  KTAddCreditViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 07/04/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class KTAddCreditViewController: KTBaseDrawerRootViewController,UITableViewDataSource, UITableViewDelegate, KTWalletViewModelDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var creditTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var addCreditTitleLbl: UILabel!
    
    private var vModel : KTWalletViewModel?
    
    private let refreshControl = UIRefreshControl()
        
    override func viewDidLoad() {
        
        if viewModel == nil {
            viewModel = KTWalletViewModel(del: self)
        }
        vModel = viewModel as? KTWalletViewModel
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor(hexString:"#006170"),
                                                                   NSAttributedStringKey.font : UIFont.init(name: "MuseoSans-900", size: 17)!]
        self.creditTextField.becomeFirstResponder()
        self.creditTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func addCredit() {
        
        (viewModel as! KTWalletViewModel).addCreditToWallet(amount: self.creditTextField.text ?? "")
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
        
    }
    
    fileprivate func createHeaderView(_ tableView: UITableView) -> UIView? {
        let keyLbl = LocalisableLabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        keyLbl.text = "str_choose_card".localized()
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return createHeaderView(tableView)
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    fileprivate func createFooterView(_ tableView: UITableView) -> UIView? {
        let conitnueButton = UIButton()
        conitnueButton.translatesAutoresizingMaskIntoConstraints = false
        conitnueButton.setTitle("txt_continue".localized(), for: .normal)
        
        conitnueButton.setTitleColor( UIColor.white, for: .normal)
        conitnueButton.setBackgroundColor(color: UIColor(hex: "#00A8A8"), forState: .normal)
        conitnueButton.titleLabel?.font = UIFont(name: "MuseoSans-500", size: 12.0)!
        conitnueButton.cornerRadius = 25
        conitnueButton.clipsToBounds = true
        conitnueButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        
        let buttonBgView : UIView = UIView(frame: CGRect(x: 0, y: 1, width: tableView.frame.width, height: 100))
        buttonBgView.backgroundColor = .white
        
        view.addSubview(buttonBgView)
        buttonBgView.addSubview(conitnueButton)
        
        [conitnueButton.heightAnchor.constraint(equalToConstant: 50),
         conitnueButton.leadingAnchor.constraint(equalTo: buttonBgView.leadingAnchor, constant: 20),
         conitnueButton.trailingAnchor.constraint(equalTo: buttonBgView.trailingAnchor, constant: -20),
         conitnueButton.centerYAnchor.constraint(equalTo: buttonBgView.centerYAnchor)].forEach({$0.isActive = true})
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return createFooterView(tableView)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTWalletViewModel).numberOfCardRows() + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : KTWalletTableViewCell =  tableView.dequeueReusableCell(withIdentifier: "WalletTableViewCellIdentifier") as! KTWalletTableViewCell
        
        if indexPath.row ==  (viewModel as! KTWalletViewModel).numberOfCardRows() {
            cell.titleLabel.text = "Debit card"
            cell.iconImageView.image  = #imageLiteral(resourceName: "empty_cards_icon")
            cell.selectedView.customBorderColor = vModel?.cardSelection(forCellIdx: indexPath.row)
            cell.selectedIconImageView.image = vModel?.cardSelectionStatusIcon(forCellIdx: indexPath.row)
        } else {
            cell.titleLabel.text = vModel?.paymentMethodName(forCellIdx: indexPath.row)
            cell.detailLable.text = vModel?.expiry(forCellIdx: indexPath.row)
            cell.iconImageView.image  = vModel?.cardIcon(forCellIdx: indexPath.row)
            cell.selectedView.customBorderColor = vModel?.cardSelection(forCellIdx: indexPath.row)
            cell.selectedIconImageView.image = vModel?.cardSelectionStatusIcon(forCellIdx: indexPath.row)
        }
                
        let backgroundCell : KTWalletTableViewBackgroundCell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewBackgroundCellIdentifier") as! KTWalletTableViewBackgroundCell
        backgroundCell.iconImageView.image = #imageLiteral(resourceName: "card_icon")
        
        animateCell(cell)
        
        return (viewModel as! KTWalletViewModel).numberOfCardRows() == 0 ? backgroundCell : cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        (viewModel as! KTWalletViewModel).rowSelected(atIndex: indexPath.row)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    func reloadTableData()
    {
        tableView.reloadData()
    }
    
}
