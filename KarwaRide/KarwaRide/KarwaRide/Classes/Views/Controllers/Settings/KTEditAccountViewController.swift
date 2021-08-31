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

        title = "account_info_title".localized()

        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name:NSNotification.Name(rawValue: "TimeToUpdateTheUINotificaiton"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func updateUI()
    {
        (viewModel as! KTEditUserViewModel).reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UITableView_Auto_Height()
    }

    func showSuccessAltAndMoveBack()
    {
    }
    
    func reloadTable()  {
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.reloadData()
        })
        
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 4

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
            let lblSectionHeader : UILabel = UILabel(frame: CGRect(x: Device.getLanguage().contains("EN") ? 30.0 : 250, y: 20.0, width: 100.0, height: 30))
            lblSectionHeader.text = "basic_info_title".localized()
            lblSectionHeader.textColor = UIColor(hexString: "#6E6E70")
            lblSectionHeader.font = UIFont(name: "MuseoSans-500", size: 13.0)!
            view.backgroundColor = UIColor(hexString: "#EFFAF8")
            view.addSubview(lblSectionHeader)
        }
        if section == 1
        {
            
            let lblSectionHeader : UILabel = UILabel(frame: CGRect(x: Device.getLanguage().contains("EN") ? 30.0 : 250, y: 20.0, width: 100.0, height: 30))
            lblSectionHeader.text = "other_title".localized()
            lblSectionHeader.textColor = UIColor(hexString: "#6E6E70")
            lblSectionHeader.font = UIFont(name: "MuseoSans-500", size: 13.0)!
            view.backgroundColor = UIColor(hexString: "#EFFAF8")
            view.addSubview(lblSectionHeader)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var cellHeight = 70

        if(indexPath.row == 3)
        {
            cellHeight = (viewModel as! KTEditUserViewModel).resendVisible() ? 50 : 20
        }

        return CGFloat(cellHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell : KTProfileCellViewController = tableView.dequeueReusableCell(withIdentifier: "identifierProfileCell") as! KTProfileCellViewController
            cell.label.text = "str_name".localized()
            cell.value.text = (viewModel as! KTEditUserViewModel).userName()
            return cell
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            let cell : KTProfileCellViewController = tableView.dequeueReusableCell(withIdentifier: "identifierProfileCell") as! KTProfileCellViewController
            cell.label.text = "str_phone".localized()
            cell.value.text = (viewModel as! KTEditUserViewModel).userPhone()
            return cell
        }
        else if indexPath.section == 0 && indexPath.row == 2 {
            let cell : KTProfileCellViewController = tableView.dequeueReusableCell(withIdentifier: "identifierProfileCell") as! KTProfileCellViewController
            cell.label.text = "str_email".localized()
            cell.value.text = (viewModel as! KTEditUserViewModel).userEmail()
            cell.warning.isHidden = (viewModel as! KTEditUserViewModel).emailVerified()
            return cell
        }
        else if indexPath.section == 0 && indexPath.row == 3 {
            let cell : KTEmailCellViewController = tableView.dequeueReusableCell(withIdentifier: "identifierEmailCell") as! KTEmailCellViewController
            cell.viewModel = (viewModel as! KTEditUserViewModel)
            cell.message.text = (viewModel as! KTEditUserViewModel).emailMessage()
            cell.message.isHidden = (viewModel as! KTEditUserViewModel).emailVerified()
            cell.resendButton.isHidden = (!(viewModel as! KTEditUserViewModel).resendVisible())
            cell.backgroundColor = UIColor(hexString: "#EFFAF8")
            return cell
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            let cell : KTProfileCellViewController = tableView.dequeueReusableCell(withIdentifier: "identifierProfileCell") as! KTProfileCellViewController
            cell.label.text = "str_gender".localized()
            cell.value.text = (viewModel as! KTEditUserViewModel).userGender()
            return cell
        }
        else if indexPath.section == 1 && indexPath.row == 1 {
            let cell : KTProfileCellViewController = tableView.dequeueReusableCell(withIdentifier: "identifierProfileCell") as! KTProfileCellViewController
            cell.label.text = "str_dob".localized()
            cell.value.text = (viewModel as! KTEditUserViewModel).userDOB()
            return cell
        }

        let cellEmpty : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "identifierProfileCell") as! KTProfileCellViewController
        return cellEmpty
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0
        {
            if indexPath.row == 0
            {
                showInputDialog(header: "str_name".localized(), subHeader: "", currentText: (viewModel as! KTEditUserViewModel).userName(), inputType: "name")
            }
            else if(indexPath.row == 2)
            {
                showInputDialog(header: "str_email".localized(), subHeader: "", currentText: (viewModel as! KTEditUserViewModel).userEmail(), inputType: "email")
            }
        }
        else if indexPath.section == 1
        {
            if indexPath.row == 0
            {
                showGenderPicker()
            }
            else if indexPath.row == 1
            {
                showDateOfBirthPicker()
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func saveName(inputText: String)
    {
        (viewModel as! KTEditUserViewModel).updateName(userName: inputText)
    }

    func saveEmail(inputText: String)
    {
        (viewModel as! KTEditUserViewModel).updateEmail(email: inputText)
    }
    
    func saveGender(gender: Int16)
    {
        (viewModel as! KTEditUserViewModel).updateGender(gender: gender)
    }

    func saveDob(date: Date)
    {
        (viewModel as! KTEditUserViewModel).updateDOB(dob: date)
    }
    
    
    
    func showInputDialog(header: String, subHeader: String, currentText : String, inputType: String)
    {
        let inputPopup = storyboard?.instantiateViewController(withIdentifier: "GenericInputVC") as! GenericInputVC
        inputPopup.previousView = self
        view.addSubview(inputPopup.view)
        addChildViewController(inputPopup)
        
        inputPopup.inputType = inputType
        inputPopup.header.text = header
        inputPopup.txtPickupHint.text = currentText
        inputPopup.lblSubHeader.text = subHeader
    }
    
    func showGenderPicker()
    {
        let alert = UIAlertController(title: "str_gender".localized(), message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "gender_array[0]".localized(), style: .default, handler: { (_) in
            self.saveGender(gender: 0)
        }))
        
        alert.addAction(UIAlertAction(title: "gender_array[1]".localized(), style: .default, handler: { (_) in
            self.saveGender(gender: 1)
        }))
        
        alert.addAction(UIAlertAction(title: "gender_array[2]".localized(), style: .default, handler: { (_) in
            self.saveGender(gender: 2)
        }))
        
        alert.addAction(UIAlertAction(title: "str_cancel".localized(), style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
        })
    }
    
    func showDateOfBirthPicker()
    {
        let minDate = Date(timeIntervalSinceReferenceDate: -1262327168000)
        let currentDate = Date()
        
        let datePicker = DatePickerDialog(textColor: UIColor(hexString: "4A4A4A"),
                                          buttonColor: UIColor(hexString: "129793"),
                                          font: UIFont(name: "MuseoSans-500", size: 18.0)!,
                                          showCancelButton: true)
        datePicker.show("Select Date of birth",
                        doneButtonTitle: "str_save".localized(),
                        cancelButtonTitle: "cancel".localized(), defaultDate: (viewModel as! KTEditUserViewModel).userDOBObject(),
                        minimumDate: minDate,
                        maximumDate: currentDate,
                        datePickerMode: .date) { (date) in
                            if let dt = date
                            {
                                self.saveDob(date: dt)
                            }
        }
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
