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

    var rebook: Bool = true
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let keyLbl = LocalisableLabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        keyLbl.localisedKey = section == 0 ? "txt_all_payment_stored".localized() : ""
        keyLbl.textAlignment = .center
        keyLbl.textColor = UIColor(hexString: "#B4B4B4")
        keyLbl.font = UIFont(name: "MuseoSans-500", size: 12.0)!
        
        let bgview : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        bgview.backgroundColor = .white
        bgview.addSubview(keyLbl)

        [keyLbl.heightAnchor.constraint(equalToConstant: 40),
         keyLbl.leadingAnchor.constraint(equalTo: bgview.leadingAnchor,constant: 0),
         keyLbl.trailingAnchor.constraint(equalTo: bgview.trailingAnchor,constant: 0),
         keyLbl.centerYAnchor.constraint(equalTo: bgview.centerYAnchor, constant: 0)].forEach({$0.isActive = true})
        
        return  bgview
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       return 50
    }
    
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
            PreviousSelectedPayment.shared.selectedPaymentMethod = nil
            cell.selectedView.customBorderColor = UIColor(hexString: "#00A8A8")
            cell.selectedIconImageView.image = #imageLiteral(resourceName: "checked_icon")
            
        } else {
            
            if indexPath.row == KTPaymentManager().getAllPayments().count {
                cell.iconImageView.image  = UIImage(named: ImageUtil.getImage("Cash"))!
                cell.titleLabel.text = "str_cash".localized()
                cell.detailLable.text = ""
                
                if PreviousSelectedPayment.shared.selectedPaymentMethod == nil {
                    cell.selectedView.customBorderColor = UIColor(hexString: "#00A8A8")
                    cell.selectedIconImageView.image = #imageLiteral(resourceName: "checked_icon")
                } else {
                    cell.selectedView.customBorderColor = UIColor(hexString: "#EBEBEB")
                    cell.selectedIconImageView.image = #imageLiteral(resourceName: "uncheck_icon")
                }
                
                
            } else {
                
                if KTPaymentManager().getAllPayments()[indexPath.row].payment_type != nil {
                    if KTPaymentManager().getAllPayments()[indexPath.row].payment_type == "WALLET" {
                        cell.iconImageView.image  = UIImage(named:"ico_wallet_new")
                        cell.titleLabel.text = "str_wallet".localized()
                        if let balance = KTPaymentManager().getAllPayments()[indexPath.row].balance {
                            cell.detailLable.text = "str_balance".localized() + " " + balance
                        }
                        
                        if let selectedPM = PreviousSelectedPayment.shared.selectedPaymentMethod {
                            if selectedPM == KTPaymentManager().getAllPayments()[indexPath.row].source! {
                                cell.selectedView.customBorderColor = UIColor(hexString: "#00A8A8")
                                cell.selectedIconImageView.image = #imageLiteral(resourceName: "checked_icon")

                            } else {
                                cell.selectedView.customBorderColor = UIColor(hexString: "#EBEBEB")
                                cell.selectedIconImageView.image = #imageLiteral(resourceName: "uncheck_icon")
                            }
                        } else {
                            cell.selectedView.customBorderColor = UIColor(hexString: "#EBEBEB")
                            cell.selectedIconImageView.image = #imageLiteral(resourceName: "uncheck_icon")
                        }
                        
                    } else {
                        
                        cell.iconImageView.image  = UIImage(named: ImageUtil.getImage(KTPaymentManager().getAllPayments()[indexPath.row].brand!))!
                        
                        if let expmonth = KTPaymentManager().getAllPayments()[indexPath.row].expiry_month, let expyear = KTPaymentManager().getAllPayments()[indexPath.row].expiry_year, let last = KTPaymentManager().getAllPayments()[indexPath.row].last_four_digits {
                            cell.detailLable.text = "EXP. " + expmonth + "/" + expyear
                            cell.titleLabel.text =  "**** **** **** " + last
                        }else {
                            
                        }
                        
                        
                        if let selectedPM = PreviousSelectedPayment.shared.selectedPaymentMethod {
                            if selectedPM == KTPaymentManager().getAllPayments()[indexPath.row].source! {
                                cell.selectedView.customBorderColor = UIColor(hexString: "#00A8A8")
                                cell.selectedIconImageView.image = #imageLiteral(resourceName: "checked_icon")

                            } else {
                                cell.selectedView.customBorderColor = UIColor(hexString: "#EBEBEB")
                                cell.selectedIconImageView.image = #imageLiteral(resourceName: "uncheck_icon")
                            }
                        }
                        else {
                            cell.selectedView.customBorderColor = UIColor(hexString: "#EBEBEB")
                            cell.selectedIconImageView.image = #imageLiteral(resourceName: "uncheck_icon")
                        }

                    }
                }
            
            }
                        
        }
            
       

        cell.selectionStyle = .none
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == KTPaymentManager().getAllPayments().count {
            self.delegate?.setSelectedPaymentType(type: "Cash", paymentMethod: nil)
            PreviousSelectedPayment.shared.selectedPaymentMethod = nil
        } else if indexPath.row == 0 {
            
            if KTPaymentManager().getAllPayments()[indexPath.row].payment_type != "WALLET" {
                let paymentMethod = KTPaymentManager().getAllPayments().filter({$0.payment_type != "WALLET"})[indexPath.row]
                selectedCardIndex = indexPath.row
                self.delegate?.setSelectedPaymentType(type: "Card", paymentMethod: paymentMethod)
                
            } else {
                self.delegate?.setSelectedPaymentType(type: "Wallet", paymentMethod: KTPaymentManager().getAllPayments()[0])
            }
            
            
        } else {
            var paymentMethod = KTPaymentManager().getAllPayments().first
            
            if KTPaymentManager().getAllPayments().filter({$0.payment_type == "WALLET"}).count > 0 {
                paymentMethod = KTPaymentManager().getAllPayments().filter({$0.payment_type != "WALLET"})[indexPath.row - 1]
            } else {
                paymentMethod = KTPaymentManager().getAllPayments().filter({$0.payment_type != "WALLET"})[indexPath.row]
            }
            
            selectedCardIndex = indexPath.row
            self.delegate?.setSelectedPaymentType(type: "Card", paymentMethod: paymentMethod)

        }
        
        self.tableView.reloadData()
        
        
    }
            
}
