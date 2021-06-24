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
    var cardSelected: Bool = false
    var selectedCardIndex = 0

    var paymentMethods: [KTPaymentMethod] = []
    var cardPaymentMethods: [KTPaymentMethod] = []

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
        
        paymentMethods.removeAll()
        cardPaymentMethods.removeAll()
        
        paymentMethods = KTPaymentManager().getAllPayments().filter({$0.payment_type == "WALLET"})
        
        cardPaymentMethods = KTPaymentManager().getAllPayments().filter({$0.payment_type != "WALLET"})
                
        paymentMethods.append(contentsOf: cardPaymentMethods)
        
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
                
                if paymentMethods[indexPath.row].payment_type != nil {
                    if paymentMethods[indexPath.row].payment_type == "WALLET" {
                        cell.iconImageView.image  = UIImage(named:"ico_wallet_new")
                        cell.titleLabel.text = "str_wallet".localized()
                        if let balance = paymentMethods[indexPath.row].balance {
                            cell.detailLable.text = balance
                        }
                    } else {
                        
                        cell.iconImageView.image  = UIImage(named: ImageUtil.getImage(paymentMethods[indexPath.row].brand!))!
                        cell.detailLable.text = "EXP. " + paymentMethods[indexPath.row].expiry_month! + "/" + paymentMethods[indexPath.row].expiry_year!
                        cell.titleLabel.text =  "**** **** **** " + paymentMethods[indexPath.row].last_four_digits!

                    }
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
            cardSelected = false
            self.delegate?.setSelectedPaymentType(type: "Cash", paymentMethod: nil)
        } else if indexPath.row == 0 {
            walletSelected = true
            cashSelected = false
            cardSelected = false
            self.delegate?.setSelectedPaymentType(type: "Wallet", paymentMethod: paymentMethods[0])
        } else {
            walletSelected = false
            cashSelected = false
            cardSelected = true
            
            
            let paymentMethod = KTPaymentManager().getAllPayments().filter({$0.payment_type != "WALLET"})[indexPath.row - 1]
            
            selectedCardIndex = indexPath.row
            self.delegate?.setSelectedPaymentType(type: "Card", paymentMethod: paymentMethod)

        }
        
        self.tableView.reloadData()
        
        
    }
    
    func paymentSelectionColor(forCellIdx idx: Int) -> UIColor {
        
        if idx == paymentMethods.count {
            if(cashSelected) {
                return UIColor(hexString: "#00A8A8")
            }
            else {
                return UIColor(hexString: "#EBEBEB")
            }
        }else if idx == 0 {
            if(walletSelected) {
                return UIColor(hexString: "#00A8A8")
            }
            return UIColor(hexString: "#EBEBEB")
        } else {
            if(cardSelected && selectedCardIndex == idx) {
                return UIColor(hexString: "#00A8A8")
            }
            return UIColor(hexString: "#EBEBEB")
        }
            
    }
    
    func paymentSelectionIcon(forCellIdx idx: Int) -> UIImage {
        
        if idx == paymentMethods.count {
            if(cashSelected) {
                return #imageLiteral(resourceName: "checked_icon")
            } else {
                return #imageLiteral(resourceName: "uncheck_icon")
            }
        } else if idx == 0 {
            if(walletSelected) {
                return #imageLiteral(resourceName: "checked_icon")
            }
            return #imageLiteral(resourceName: "uncheck_icon")
        } else {
            if(cardSelected && selectedCardIndex == idx) {
                return #imageLiteral(resourceName: "checked_icon")
            }
            return #imageLiteral(resourceName: "uncheck_icon")
        }
                
    }
    
}
