//
//  KTPromotionsBottomSheetVC.swift
//  KarwaRide
//
//  Created by Piecyfer on 18/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import UBottomSheet
import FittedSheets
import Spring
import Kingfisher

class KTPromotionsBottomSheetVC: KTBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfPromoCode: UITextField!
    @IBOutlet weak var btnApply: SpringButton!
    @IBOutlet weak var btnShowMore: UIButton!
    @IBOutlet weak var uiPromoInput: SpringView!
    @IBOutlet weak var lblHeading: UILabel!
    
    var pickupDropoff: PromotionParams?
    
    weak var sheet: SheetViewController? {
        didSet {
            self.setSheetClosure()
        }
    }
    private var vModel: KTPromotionsViewModel?
    weak var previousView : KTCreateBookingViewController?
    var previousPromo : String?
    
    override func viewDidLoad() {
        if viewModel == nil
        {
            viewModel = KTPromotionsViewModel(del: self)
        }
        vModel = viewModel as? KTPromotionsViewModel
        super.viewDidLoad()
        
        self.setupView()
        self.setupTBL()
        self.setupKeyboardNotifications()
    }
    
    private func setupView() {
        btnShowMore.setImage(UIImage(named: "ic_bottom_arrow_stack"), for: .normal)
        btnShowMore.setImage(UIImage(named: "ic_bottom_arrow_stack"), for: .highlighted)
        
        tfPromoCode.delegate = self
        tfPromoCode.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.isEmpty ?? false {
            if let promo = previousPromo, !promo.isEmpty {
                let title = NSAttributedString(
                    string: "promo_apply".localized(),
                    attributes: [.font: UIFont(name: "MuseoSans-900", size: 12.0)!, .foregroundColor: UIColor.white]
                )
                btnApply.setAttributedTitle(title, for: .normal)
            }
        }
    }
    
    func setupKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardNotification(_ notification: NSNotification) {
        let isShowing = notification.name == .UIKeyboardWillShow
        if isShowing {
            self.tableView.isHidden = true
            self.lblHeading.isHidden = true
            self.btnShowMore.isHidden = true
            self.resizeSheetOnKeyboardNotify(isKeyboardActive: true)
        }
        else {
            self.tableView.isHidden = false
            self.lblHeading.isHidden = false
            self.btnShowMore.isHidden = (self.viewModel as! KTPromotionsViewModel).numberOfRows() > 3 ? false : true
            self.resizeSheetOnKeyboardNotify(isKeyboardActive: false)
        }
    }
    
    deinit {
        print("KTPromotionsBottomSheetVC->deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupPromoState() {
        var btnText = "promo_apply".localized()
        if let promo = previousPromo, !promo.isEmpty {
            btnText = "str_remove".localized()
            lblHeading.text = "str_applied_promo".localized() + " (\(promo))"
        } else {
            btnText = "promo_apply".localized()
            lblHeading.text = "str_promo_codes".localized()
        }
        let title = NSAttributedString(
            string: btnText,
          attributes: [.font: UIFont(name: "MuseoSans-900", size: 12.0)!, .foregroundColor: UIColor.white]
        )
        btnApply.setAttributedTitle(title, for: .normal)
        tfPromoCode.text = previousPromo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupPromoState()
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
        vModel!.fetchPromotions(params: self.pickupDropoff!)
    }
    
    private func setSheetClosure() {
        sheet?.sizeChanged = { [weak self] (sheetViewController, sheetSize, newHeight) in
            guard let `self` = self else {return}
            if sheetSize == .percent(0.70) {
                self.btnShowMore.isHidden = (self.viewModel as! KTPromotionsViewModel).numberOfRows() > 3 ? false : true
            }
            else {
                self.btnShowMore.isHidden = true
            }
        }
    }
    
    @IBAction func onClickShowMore(_ sender: Any) {
        sheet?.resize(to: .marginFromTop(80), duration: 0.2, options: .curveEaseIn, animated: true) { [weak self] in
            guard let `self` = self else {return}
            self.btnShowMore.isHidden = true
        }
    }
    
    private func resizeSheetOnKeyboardNotify(isKeyboardActive: Bool) {
        sheet?.resize(to: isKeyboardActive ? .percent(0.30) : .percent(0.70), duration: 0.2, options: .curveEaseIn, animated: true)
    }
    
    @IBAction func btnApplyTouchDown(_ sender: SpringButton){
        springAnimateButtonTapIn(button: btnApply)
    }
    
    @IBAction func btnApplyTouchUpOutside(_ sender: SpringButton){
        springAnimateButtonTapOut(button: btnApply)
    }
    
    @IBAction func onClickApply(_ sender: Any){
        springAnimateButtonTapOut(button: btnApply)
        if tfPromoCode.text != nil
        {
            if((tfPromoCode.text?.trimmingCharacters(in: .whitespacesAndNewlines).length)! > 3)
            {
                if let promo = previousPromo, !promo.isEmpty {
                    previousView?.removePromoTapped()
                }
                else {
                    previousView?.applyPromoTapped(tfPromoCode.text!.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                self.sheet?.attemptDismiss(animated: true)
            }
            else
            {
                showLengthError()
            }
        }
    }
    
    func showLengthError()
    {
        let alertController = UIAlertController(title: "error_sr".localized(), message: "promo_length_error".localized(), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localized(), style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension KTPromotionsBottomSheetVC: KTPromotionsViewModelDelegate {
    func reloadTable() {
        tableView.reloadData()
        self.btnShowMore.isHidden = (self.viewModel as! KTPromotionsViewModel).numberOfRows() > 3 ? false : true
    }
    
    func showEmptyMessage(message: String) {
        self.tableView.setEmptyMessage(message)
    }
}

extension KTPromotionsBottomSheetVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension KTPromotionsBottomSheetVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTPromotionsViewModel).numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: KTPromotionCell = tableView.dequeueReusableCell(withIdentifier: String(describing: KTPromotionCell.self)) as! KTPromotionCell
        var isApplied = false
        let promotionData = vModel!.getPromotion(at: indexPath.row)
        if promotionData.code == previousPromo {
            isApplied = true
        }
        cell.configPromoBottomSheetCell(data: promotionData, isApplied: isApplied)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let promoCode = vModel!.getPromotion(at: indexPath.row).code {
            previousView?.applyPromoTapped(promoCode)
            self.sheet?.attemptDismiss(animated: true)
        }
    }
    
    private func setupTBL(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: String(describing: KTPromotionCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: KTPromotionCell.self))
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        }
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
}
