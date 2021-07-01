//
//  KTPaymentMethodSelectionView.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 21/04/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import Spring
import UBottomSheet

protocol PaymethodSelectionDelegate {
    func setSelectedPaymentType(type: String, paymentMethod: KTPaymentMethod?)
    func closeSheet()
}

extension PaymethodSelectionDelegate {
    func setSelectedPaymentType(type: String, paymentMethod: KTPaymentMethod?) {
        
    }
}

class KTPaymentMethodSelectionView: SpringView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var tapView: UIView!

    
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
                
    }

}

class PaymentSelectionBottomSheetController: UIViewController, Draggable{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!

    var cashSelected: Bool = true
    var walletSelected: Bool = false
    var cardSelected: Bool = false
    var selectedCardIndex = 0
      
    var delegate: PaymethodSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "PaymentMethodSelectTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentMethodSelectTableViewCelllIdentifier")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //adds pan gesture recognizer to draggableView()
        sheetCoordinator?.startTracking(item: self)
    }

//  MARK: Draggable protocol implementations

    var sheetCoordinator: UBottomSheetCoordinator?

    func draggableView() -> UIScrollView? {
        return tableView
    }
    
    @IBAction func closeButtonClicked() {
        delegate?.closeSheet()
    }
}

extension PaymentSelectionBottomSheetController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return KTPaymentManager().getAllPayments().count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.separatorStyle = .none
        let cell : PaymentMethodSelectTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodSelectTableViewCelllIdentifier") as! PaymentMethodSelectTableViewCell
        
        if KTPaymentManager().getAllPayments().count == 0 {
            cell.iconImageView.image  = UIImage(named: ImageUtil.getImage("Cash"))!
            cell.titleLabel.text = "str_cash".localized()
            cell.detailLable.text = ""
            
        } else {
            
            if indexPath.row == KTPaymentManager().getAllPayments().count {
                cell.iconImageView.image  = UIImage(named: ImageUtil.getImage("Cash"))!
                cell.titleLabel.text = "str_cash".localized()
                cell.detailLable.text = ""
            } else {
                
                if KTPaymentManager().getAllPayments()[indexPath.row].payment_type != nil {
                    if KTPaymentManager().getAllPayments()[indexPath.row].payment_type == "WALLET" {
                        cell.iconImageView.image  = UIImage(named:"ico_wallet_new")
                        cell.titleLabel.text = "str_wallet".localized()
                        if let balance = KTPaymentManager().getAllPayments()[indexPath.row].balance {
                            cell.detailLable.text = "str_balance".localized() + " " + balance
                        }
                    } else {
                        
                        cell.iconImageView.image  = UIImage(named: ImageUtil.getImage(KTPaymentManager().getAllPayments()[indexPath.row].brand!))!
                        
                        if let expmonth = KTPaymentManager().getAllPayments()[indexPath.row].expiry_month, let expyear = KTPaymentManager().getAllPayments()[indexPath.row].expiry_year, let last = KTPaymentManager().getAllPayments()[indexPath.row].last_four_digits {
                            cell.detailLable.text = "EXP. " + expmonth + "/" + expyear
                            cell.titleLabel.text =  "**** **** **** " + last
                        }else {
                            
                        }
                        
                        

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
        
        if indexPath.row == KTPaymentManager().getAllPayments().count {
            cashSelected = true
            walletSelected = false
            cardSelected = false
            self.delegate?.setSelectedPaymentType(type: "Cash", paymentMethod: nil)
        } else if indexPath.row == 0 {
            
            if KTPaymentManager().getAllPayments()[indexPath.row].payment_type != "WALLET" {
                walletSelected = false
                cashSelected = false
                cardSelected = true
                let paymentMethod = KTPaymentManager().getAllPayments().filter({$0.payment_type != "WALLET"})[indexPath.row]
                selectedCardIndex = indexPath.row
                self.delegate?.setSelectedPaymentType(type: "Card", paymentMethod: paymentMethod)
                
            } else {
                walletSelected = true
                cashSelected = false
                cardSelected = false
                self.delegate?.setSelectedPaymentType(type: "Wallet", paymentMethod: KTPaymentManager().getAllPayments()[0])
            }
            
            
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
        
        if idx == KTPaymentManager().getAllPayments().count {
            if(cashSelected) {
                return UIColor(hexString: "#00A8A8")
            }
            else {
                return UIColor(hexString: "#EBEBEB")
            }
        }else if idx == 0 {
            if(walletSelected) {
                return UIColor(hexString: "#00A8A8")
            } else if (cardSelected && KTPaymentManager().getAllPayments().filter({$0.payment_type == "WALLET"}).count == 0) {
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
        
        if idx == KTPaymentManager().getAllPayments().count {
            if(cashSelected) {
                return #imageLiteral(resourceName: "checked_icon")
            } else {
                return #imageLiteral(resourceName: "uncheck_icon")
            }
        } else if idx == 0 {
            if(walletSelected) {
                return #imageLiteral(resourceName: "checked_icon")
            }
            else if (cardSelected && KTPaymentManager().getAllPayments().filter({$0.payment_type == "WALLET"}).count == 0) {
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
