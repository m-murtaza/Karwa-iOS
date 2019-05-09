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
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        UITableView_Auto_Height()
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
            view.backgroundColor = UIColor(hexString: "#EFFAF8")
            view.addSubview(lblSectionHeader)
        }
        if section == 1
        {
            
            let lblSectionHeader : UILabel = UILabel(frame: CGRect(x: 30.0, y: 20.0, width: 100.0, height: 30))
            lblSectionHeader.text = "Other"
            lblSectionHeader.textColor = UIColor(hexString: "#6E6E70")
            lblSectionHeader.font = UIFont(name: "MuseoSans-500", size: 13.0)!
            view.backgroundColor = UIColor(hexString: "#EFFAF8")
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
            cell.value.text = (viewModel as! KTEditUserViewModel).userName()
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            cell.label.text = "Phone"
            cell.value.text = (viewModel as! KTEditUserViewModel).userPhone()
        }
        else if indexPath.section == 0 && indexPath.row == 2 {
            cell.label.text = "Email"
            cell.value.text = (viewModel as! KTEditUserViewModel).userEmail()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            cell.label.text = "Gender"
            cell.value.text = (viewModel as! KTEditUserViewModel).userGender()
        }
        else if indexPath.section == 1 && indexPath.row == 1 {
            cell.label.text = "Date of birth"
            cell.value.text = (viewModel as! KTEditUserViewModel).userDOB()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0
        {
            if indexPath.row == 0
            {
                showInputDialog(header: "Name", currentText: (viewModel as! KTEditUserViewModel).userName(), inputType: "name")
            }
            else if(indexPath.row == 2)
            {
                showInputDialog(header: "Email", currentText: (viewModel as! KTEditUserViewModel).userEmail(), inputType: "email")
            }
        }
        else if indexPath.section == 1
        {
            if indexPath.row == 0
            {
                //TODO: show Gender spinner
            }
            else if indexPath.row == 1
            {
                //TODO: show DOB Spinner
            }
        }
    }
    
    func saveName(inputText: String)
    {
        //TODO:
    }

    func saveEmail(inputText: String)
    {
        //TODO:
    }
    
    func saveGender(inputText: String)
    {
        //TODO:
    }

    func saveDob(inputText: String)
    {
        //TODO:
    }
    
    
    
    func showInputDialog(header: String, currentText : String, inputType: String)
    {
        let inputPopup = storyboard?.instantiateViewController(withIdentifier: "GenericInputVC") as! GenericInputVC
        inputPopup.previousView = self
//        inputPopup.view.frame = self.view.bounds
        view.addSubview(inputPopup.view)
        addChildViewController(inputPopup)
        
        inputPopup.inputType = inputType
        inputPopup.header.text = header
        inputPopup.txtPickupHint.text = currentText
    }
    
    func UITableView_Auto_Height()
    {
        if(self.tableView.contentSize.height < self.tableView.frame.height){
            var frame: CGRect = self.tableView.frame;
            frame.size.height = self.tableView.contentSize.height;
            self.tableView.frame = frame;
        }
    }
}
