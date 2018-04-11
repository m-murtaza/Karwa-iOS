//
//  KTFarePopupViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/10/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTFarePopViewDelegate {
    func closeFareEstimate()
    //func cancelDoneSuccess()
}

class KTFarePopupViewController: PopupVC, KTFarePopupViewModelDelegate, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblTotal : UILabel!
    @IBOutlet weak var lblTotalTitle : UILabel!
    @IBOutlet weak var tblView : UITableView!
    
    @IBOutlet weak var constraintViewHeight : NSLayoutConstraint!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    
    var delegate : KTFarePopViewDelegate?
    private var vModel : KTFarePopupViewModel?
    
    override func viewDidLoad() {
        if viewModel == nil {
            viewModel = KTFarePopupViewModel(del: self)
        }
        
        vModel = viewModel as? KTFarePopupViewModel
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        viewPopupUI.layer.cornerRadius = 16
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateViewForSmallSize() {
        
        constraintViewHeight.constant -= 100
        constraintTableViewHeight.constant -= 100
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func set(header: [KTKeyValue]?, body: [KTKeyValue]?, title: String, total: String, titleTotal: String)  {
        vModel?.set(header: header, body: body, title: title, total: total,titleTotal: titleTotal)
    }
    
    func setTitleLable(title: String) {
        lblTitle.text = title
    }
    
    func setTitleTotalLabel(titalTotal: String) {
        lblTotalTitle.text = titalTotal
    }
    func setTotalLabel(total: String) {
        lblTotal.text = total
    }
    
    func reloadTable() {
        tblView.reloadData()
    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        self.delegate?.closeFareEstimate()
    }
    
    //MARK:- UITable view delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (vModel?.numberOfRowsInSection(section: section))!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : KTFarePopupTableViewCell = tblView.dequeueReusableCell(withIdentifier: "FareCellReuseIdentifier") as! KTFarePopupTableViewCell
        
        cell.key.text = vModel?.key(forIndex: indexPath.row, section: indexPath.section)
        cell.value.text = vModel?.value(forIndex: indexPath.row, section: indexPath.section)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 25
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame:
            CGRect(x: 0, y: 0, width: 0 , height: 0))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //Say 2 section with two different look
        if section == 0{
            
            return UIView(frame:
                CGRect(x: 0, y: 0, width: 0 , height: 0))
        }
        else{
            let header = tableView.dequeueReusableCell(withIdentifier: "FareSectionSapratorCellIdentifier")!
            
            return header.contentView
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return (vModel?.numberOfSection())!
    }
    
    
}
