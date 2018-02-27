//
//  KTSettingsViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/26/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTSettingsViewController: KTBaseViewController ,KTSettingsViewModelDelegate ,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        viewModel = KTSettingsViewModel(del: self)
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
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
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 1
        if section == 2 {
            
            numRows = 2
        }
        else if section == 3 {
            numRows = 2
        }
        return numRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var height:CGFloat = 20.0
        if section == 0 {
            height = 40
        }
        else if section == 2 {
            height = 50
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view : UIView = UIView()
        //if section == 0 || section == 1 || section == 2 ||{
            view.backgroundColor = UIColor(hexString: "#EFFAF8")
        //}
        if section == 2 {
            
            let lblSectionHeader : UILabel = UILabel(frame: CGRect(x: 30.0, y: 20.0, width: 100.0, height: 30))
            lblSectionHeader.text = "FAVORITES"
            lblSectionHeader.textColor = UIColor(hexString: "#6E6E70")
            lblSectionHeader.font = UIFont(name: "MuseoSans-500", size: 13.0)!
            view.addSubview(lblSectionHeader)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 50.0
        
        if indexPath.row == 0 && indexPath.section == 0 {
                height = 80.0
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "userInfoCellIdentifier")
            
            guard let _ = cell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
            }
            
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
            guard let _ = cell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
            }
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            (cell as! KTSettingsImgTextTableViewCell).lblText.text = "Change Password"
            (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconPassword")
        }
        
        else if indexPath.section == 2 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
            guard let _ = cell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
            }
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            (cell as! KTSettingsImgTextTableViewCell).lblText.text = "Home"
            (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconHome")
        }
        else if indexPath.section == 2 && indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
            guard let _ = cell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
            }
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            (cell as! KTSettingsImgTextTableViewCell).lblText.text = "Work"
            (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconWork")
        }
        else if indexPath.section == 3  {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "CalendarShortcutCellIdentifier")
                guard let _ = cell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
                }
                //cell?.accessoryType = UITableViewCellAccessoryType.none
                cell?.accessoryView = (cell as! KTSettingCalendarTableViewCell).onOffSwitch
                (cell as! KTSettingCalendarTableViewCell).lblText.text = "Calendar Shortcut"
                (cell as! KTSettingCalendarTableViewCell).imgIcon.image = UIImage(named: "SettingIconCalendar")
            }
            else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
                guard let _ = cell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
                }
                cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                (cell as! KTSettingsImgTextTableViewCell).lblText.text = "Rate This App"
                (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconRate")
                
            }
            
        }
        else if indexPath.section == 4 {
            
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
                guard let _ = cell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
                }
                cell?.accessoryType = UITableViewCellAccessoryType.none
                (cell as! KTSettingsImgTextTableViewCell).lblText.text = "Logout"
                (cell as! KTSettingsImgTextTableViewCell).lblText.textColor = UIColor(hexString: "#E74C3C")
                (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconLogout")
                
            }
        }
        
        
        return cell!
    }
    
    

}
