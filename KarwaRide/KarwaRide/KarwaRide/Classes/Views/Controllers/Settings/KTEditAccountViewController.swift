//
//  KTEditAccountViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring

class KTEditAccountViewController: KTBaseViewController,KTEditUserViewModelDelegate,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad()
    {
        viewModel = KTEditUserViewModel(del: self)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        super.viewDidLoad()
        
        self.tableView.rowHeight = 70
        self.tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }


    func showSuccessAltAndMoveBack()
    {
    }
    
    func reloadTable()  {
        self.tableView.reloadData()
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 3

        if section == 1
        {
            numRows = 2
        }

        return numRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view : UIView = UIView()
        if section == 0
        {
            let lblSectionHeader : UILabel = UILabel(frame: CGRect(x: 30.0, y: 20.0, width: 100.0, height: 30))
            lblSectionHeader.text = "Basic Info"
            lblSectionHeader.textColor = UIColor(hexString: "#6E6E70")
            lblSectionHeader.font = UIFont(name: "MuseoSans-500", size: 13.0)!
            view.addSubview(lblSectionHeader)
        }
        if section == 1
        {
            let lblSectionHeader : UILabel = UILabel(frame: CGRect(x: 30.0, y: 20.0, width: 100.0, height: 30))
            lblSectionHeader.text = "Other"
            lblSectionHeader.textColor = UIColor(hexString: "#6E6E70")
            lblSectionHeader.font = UIFont(name: "MuseoSans-500", size: 13.0)!
            view.addSubview(lblSectionHeader)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell : KTProfileCellViewController = tableView.dequeueReusableCell(withIdentifier: "identifierProfileCell") as! KTProfileCellViewController

        if indexPath.section == 0 && indexPath.row == 0 {
            cell.label.text = "Name"
            cell.value.text = "OOSAMA ASHRAF"
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            cell.label.text = "Phone"
            cell.value.text = "99999999"
        }
        else if indexPath.section == 0 && indexPath.row == 2 {
            cell.label.text = "Email"
            cell.value.text = "osama.ashraf2005@gmail.com"
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            cell.label.text = "Gender"
            cell.value.text = "Male"
        }
        else if indexPath.section == 1 && indexPath.row == 1 {
            cell.label.text = "Date of birth"
            cell.value.text = "31 Mar 1987"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0
            {
                self.performSegue(name: "segueSettingToEditAccount")
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0
            {
                self.performSegue(name: "segueSettingToChangePassword")
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0
            {
                self.performSegue(name: "segueSettingsToSetHome")
            }
            else if indexPath.row == 1 {
                self.performSegue(name: "segueSettingsToSetWork")
            }
        }
        else if indexPath.section == 3 {
            if indexPath.row == 0{
                (viewModel as! KTSettingsViewModel).rateApplication()
            }
        }
            
        else if indexPath.section == 4 {
            if indexPath.row == 0 {
                (viewModel as! KTSettingsViewModel).startLogoutProcess()
            }
        }
    }
}
