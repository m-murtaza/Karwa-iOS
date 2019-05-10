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
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad()
    {
        viewModel = KTEditUserViewModel(del: self)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        super.viewDidLoad()
        
        self.tableView.rowHeight = 70
        self.tableView.tableFooterView = UIView()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
    }

    @objc func refresh(sender:AnyObject)
    {
//        (viewModel as! KTMyTripsViewModel).fetchBookings()
    }
    
    func showProgress()
    {
        refreshControl.beginRefreshing()
    }
    
    func hideProgress()
    {
        refreshControl.endRefreshing()
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
    
    
    
    func showInputDialog(header: String, currentText : String, inputType: String)
    {
        let inputPopup = storyboard?.instantiateViewController(withIdentifier: "GenericInputVC") as! GenericInputVC
        inputPopup.previousView = self
        view.addSubview(inputPopup.view)
        addChildViewController(inputPopup)
        
        inputPopup.inputType = inputType
        inputPopup.header.text = header
        inputPopup.txtPickupHint.text = currentText
    }
    
    func showGenderPicker()
    {
        let alert = UIAlertController(title: "Select Gender", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Prefer not to mention", style: .default, handler: { (_) in
            self.saveGender(gender: 0)
        }))
        
        alert.addAction(UIAlertAction(title: "Male", style: .default, handler: { (_) in
            self.saveGender(gender: 1)
        }))
        
        alert.addAction(UIAlertAction(title: "Female", style: .default, handler: { (_) in
            self.saveGender(gender: 2)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
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
                        doneButtonTitle: "Save",
                        cancelButtonTitle: "Cancel", defaultDate: (viewModel as! KTEditUserViewModel).userDOBObject(),
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
