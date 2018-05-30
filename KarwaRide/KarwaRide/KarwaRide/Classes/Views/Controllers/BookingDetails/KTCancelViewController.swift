//
//  CancelViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/5/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTCancelViewDelegate {
    func closeCancel()
    func cancelDoneSuccess()
}

class KTCancelViewController: PopupVC,KTCancelViewModelDelegate,KTCancelReasonCellDelegate, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tblView : UITableView!
    var delegate : KTCancelViewDelegate?
    
    var bookingStatii : Int32 = 0
    var bookingId : String = ""
    var selectedOption : Int  = -1
    
    private var vModel : KTCancelViewModel?
    override func viewDidLoad() {
    
        if viewModel == nil {
            viewModel = KTCancelViewModel(del: self)
            vModel = viewModel as? KTCancelViewModel
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewPopupUI.layer.cornerRadius = 16
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getBookingStatii() -> Int32 {
        
        return bookingStatii
    }
    
    func getBookingID() -> String {
        
        return bookingId
    }
    
    func reloadTable() {
        tblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return vModel!.numberOfRows()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : KTCancelReasonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "reasonsCellIdentifier", for: indexPath) as! KTCancelReasonTableViewCell
        
        cell.delegate = self
        cell.lblReason?.text = vModel?.reasonTitle(idx: indexPath.row)
        cell.btnSelection?.tag = indexPath.row
        if indexPath.row == selectedOption {
            cell.btnSelection?.isHighlighted = true
        }
        else {
            cell.btnSelection?.isHighlighted = false
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell : KTCancelReasonTableViewCell = tableView.cellForRow(at: indexPath) as! KTCancelReasonTableViewCell
        cell.cancelOptionSelected(tag: indexPath.row)
    }
    
    func optionSelected(atIdx idx: Int) {
        
        selectedOption = idx
        tblView.reloadData()
    }
    
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        delegate?.closeCancel()
    }
    @IBAction func btnSubmitTapped(_ sender: Any) {
        vModel?.btnSubmitTapped(selectedIdx: selectedOption)
    }
    
    func cancelSuccess() {
        
        delegate?.cancelDoneSuccess()
    }
}
