//
//  KTPaymentMethodSelectionView.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 21/04/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

protocol PaymethodSelectionDelegate {
    func setSelectedPaymentType(type: String, paymentMethod: KTPaymentMethod?)
}

extension PaymethodSelectionDelegate {
    func setSelectedPaymentType(type: String, paymentMethod: KTPaymentMethod?) {
        
    }
}

class KTPaymentMethodSelectionView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleBackGroundView: UIView!
    @IBOutlet var tapView: UIView!

    var cashSelected: Bool = true
    var walletSelected: Bool = false

    var paymentMethods: [KTPaymentMethod] = []
    
    var delegate: PaymethodSelectionDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("KTPaymentMethodSelectionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        tableView.register(UINib(nibName: "PaymentMethodSelectTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentMethodSelectTableViewCelllIdentifier")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchnPaymentMethods()
        
    }

    func fetchnPaymentMethods() {
        paymentMethods = KTPaymentManager().getAllPayments().filter({$0.payment_type == "WALLET"})
        self.tableView.reloadData()
    }
}

extension KTPaymentMethodSelectionView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.separatorStyle = .none
        let cell : PaymentMethodSelectTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodSelectTableViewCelllIdentifier") as! PaymentMethodSelectTableViewCell
        
        if paymentMethods.count == 0 {
            cell.iconImageView.image  = UIImage(named: ImageUtil.getImage("Cash"))!
            cell.titleLabel.text = "str_cash".localized()
            cell.detailLable.text = ""
            
        } else {
            
            if indexPath.row == paymentMethods.count {
                cell.iconImageView.image  = UIImage(named: ImageUtil.getImage("Cash"))!
                cell.titleLabel.text = "str_cash".localized()
                cell.detailLable.text = ""
            } else {
                cell.iconImageView.image  = UIImage(named:"ico_wallet_new")
                cell.titleLabel.text = "str_wallet".localized()
                
                if let balance = paymentMethods[0].balance {
                    cell.detailLable.text = balance
                }
                
            }
                        
        }
            
        cell.selectedView.customBorderColor = paymentSelectionColor(forCellIdx: indexPath.row)
        cell.selectedIconImageView.image = paymentSelectionIcon(forCellIdx: indexPath.row)

        cell.selectionStyle = .none
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == paymentMethods.count {
            cashSelected = true
            walletSelected = false
        } else {
            walletSelected = true
            cashSelected = false
        }
        
        self.tableView.reloadData()
        
        self.delegate?.setSelectedPaymentType(type: cashSelected == true ? "Cash" : "Wallet", paymentMethod: walletSelected == true ? paymentMethods[0] : nil)
        
    }
    
    func paymentSelectionColor(forCellIdx idx: Int) -> UIColor {
        
        if idx == paymentMethods.count {
            if(cashSelected) {
                return UIColor(hexString: "#00A8A8")
            }
            else {
                return UIColor(hexString: "#EBEBEB")
            }
        } else {
            if(walletSelected) {
                return UIColor(hexString: "#00A8A8")
            }
            else {
                return UIColor(hexString: "#EBEBEB")
            }
        }
    
    }
    
    func paymentSelectionIcon(forCellIdx idx: Int) -> UIImage {
        
        if idx == paymentMethods.count {
            if(cashSelected) {
                return #imageLiteral(resourceName: "checked_icon")
            } else {
                return #imageLiteral(resourceName: "uncheck_icon")
            }
        } else {
            
            if(walletSelected) {
                return #imageLiteral(resourceName: "checked_icon")
            } else {
                return #imageLiteral(resourceName: "uncheck_icon")
            }
        }
        
    }
    
}
