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
    @IBOutlet weak var lblVersion : UILabel!
    
    override func viewDidLoad() {
        viewModel = KTSettingsViewModel(del: self)
        super.viewDidLoad()
        
        setVersionLable()
        
        title = "action_settings".localized()

        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: (Selector(("updateUI"))), name:NSNotification.Name(rawValue: "TimeToUpdateTheUINotificaiton"), object: nil)
      addMenuButton()
    }

    func updateUI()
    {
        (viewModel as! KTSettingsViewModel).reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    func setVersionLable()  {
        
        lblVersion.text = (viewModel as! KTSettingsViewModel).appVersion()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueSettingsToSetHome" {
            let destination : KTSetHomeWorkViewController = segue.destination as! KTSetHomeWorkViewController
            destination.bookmarkType = BookmarkType.home
            destination.previousView = self
        }
        else if segue.identifier == "segueSettingsToSetWork" {
            let destination : KTSetHomeWorkViewController = segue.destination as! KTSetHomeWorkViewController
            destination.bookmarkType = BookmarkType.work
            destination.previousView = self
        }
    }
    
    
    
    func reloadTable()  {
        self.tableView.reloadData()
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 1
        if section == 2 {
            
            numRows = 2
        }
        /*else if section == 3 {
            numRows = 2
        }*/
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
            let lblSectionHeader : UILabel = UILabel(frame: CGRect(x: Device.getLanguage().contains("ER") ? 30.0 : 250, y: 20.0, width: 100.0, height: 30))
            lblSectionHeader.text = "txt_favourites".localized()
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
            
            let name = (viewModel as! KTSettingsViewModel).userName()
            let phone = (viewModel as! KTSettingsViewModel).userPhone()
            let perCompletion = (viewModel as! KTSettingsViewModel).percentageCompletion()
            let isEmailVerified = (viewModel as! KTSettingsViewModel).isEmailVerified()

            (cell as! KTSettingsProfileTableViewCell).setUserInfo(name: name, phone: phone, completeness: perCompletion, emailVerified: isEmailVerified)

            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
            guard let _ = cell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
            }
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            (cell as! KTSettingsImgTextTableViewCell).lblText.text = "changePass".localized()
            (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconPassword")
        }
        
        else if indexPath.section == 2 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
            guard let _ = cell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
            }
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            (cell as! KTSettingsImgTextTableViewCell).lblText.text = "strHome".localized()
            (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconHome")
        }
        else if indexPath.section == 2 && indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
            guard let _ = cell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
            }
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            (cell as! KTSettingsImgTextTableViewCell).lblText.text = "strWork".localized()
            (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconWork")
        }
        else if indexPath.section == 3  {
            /*if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "CalendarShortcutCellIdentifier")
                guard let _ = cell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
                }
                //cell?.accessoryType = UITableViewCellAccessoryType.none
                cell?.accessoryView = (cell as! KTSettingCalendarTableViewCell).onOffSwitch
                (cell as! KTSettingCalendarTableViewCell).lblText.text = "Calendar Shortcut"
                (cell as! KTSettingCalendarTableViewCell).imgIcon.image = UIImage(named: "SettingIconCalendar")
            }
            else */if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
                guard let _ = cell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
                }
                cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                (cell as! KTSettingsImgTextTableViewCell).lblText.text = "strRateApp".localized()
                (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconRate")
                
            }
            
        }
        else if indexPath.section == 4 {
            
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
                guard let _ = cell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
                }
//                cell?.accessoryType = UITableViewCellAccessoryType.none
                (cell as! KTSettingsImgTextTableViewCell).lblText.text = "strLogout".localized()
                (cell as! KTSettingsImgTextTableViewCell).lblText.textColor = UIColor(hexString: "#E74C3C")
                (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconLogout")
                
            }
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            
            if indexPath.row == 0 {
                
                self.performSegue(name: "segueSettingToEditAccount")
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                self.performSegue(name: "segueSettingToChangePassword")
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
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
    
    //MARK: - Logout
    func showLogoutConfirmAlt() {
        
        let logoutAlt = UIAlertController(title: "strLogout".localized(), message: "str_confirm_logout".localized(), preferredStyle: UIAlertControllerStyle.alert)
        
        logoutAlt.addAction(UIAlertAction(title: "str_yes".localized(), style: UIAlertActionStyle.destructive, handler: { (action) in
            
            (self.viewModel as! KTSettingsViewModel).logout()
        }))
        
        logoutAlt.addAction(UIAlertAction(title: "cancel".localized(), style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(logoutAlt, animated: true, completion: nil)
    }
    
    

}
