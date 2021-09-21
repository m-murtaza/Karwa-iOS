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
    
    var otpEnabledStatus: String = "false"
    
    override func viewDidLoad() {
        viewModel = KTSettingsViewModel(del: self)
        super.viewDidLoad()
        
        setVersionLable()
        

        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name:NSNotification.Name(rawValue: "TimeToUpdateTheUINotificaiton"), object: nil)
      addMenuButton()
        
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        
        self.title = "action_settings".localized()
        self.tabBarItem.title = "action_settings".localized()


    }

    @objc func updateUI()
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
            (cell as! KTSettingsImgTextTableViewCell).otpSwitch.isHidden = true
            (cell as! KTSettingsImgTextTableViewCell).detailText.isHidden = true
        }
        
        else if indexPath.section == 2 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
            guard let _ = cell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
            }
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            (cell as! KTSettingsImgTextTableViewCell).lblText.text = "strHome".localized()
            (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconHome")
            (cell as! KTSettingsImgTextTableViewCell).otpSwitch.isHidden = true
            (cell as! KTSettingsImgTextTableViewCell).detailText.isHidden = true

        }
        else if indexPath.section == 2 && indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
            guard let _ = cell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
            }
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            (cell as! KTSettingsImgTextTableViewCell).lblText.text = "strWork".localized()
            (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconWork")
            (cell as! KTSettingsImgTextTableViewCell).otpSwitch.isHidden = true
            (cell as! KTSettingsImgTextTableViewCell).detailText.isHidden = true

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
            else */
            if indexPath.row == 0{
                cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
                guard let _ = cell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
                }
                
                (cell as! KTSettingsImgTextTableViewCell).otpSwitch.isHidden = false
                
                if let otpEnabled: Bool = UserDefaults.standard.value(forKey: "OTPEnabled") as? Bool, otpEnabled == true {
                    otpEnabledStatus = "false"
                    (cell as! KTSettingsImgTextTableViewCell).otpSwitch.isOn = otpEnabled
//                    (cell as! KTSettingsImgTextTableViewCell).otpSwitch.setImage(#imageLiteral(resourceName: "ic_confirmed"), for: .normal)
                } else {
                    (cell as! KTSettingsImgTextTableViewCell).otpSwitch.isOn = false
                    otpEnabledStatus = "true"
//                    (cell as! KTSettingsImgTextTableViewCell).otpSwitch.setImage(#imageLiteral(resourceName: "ic_arrived"), for: .normal)
                }
                
                (cell as! KTSettingsImgTextTableViewCell).otpSwitch.addTarget(self, action: #selector(setOneTimePassword(sender:)), for: .valueChanged)
                
                (cell as! KTSettingsImgTextTableViewCell).lblText.text = "str_otp_settings".localized()
                (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "otp_ico_setting")
                (cell as! KTSettingsImgTextTableViewCell).detailText.isHidden = false

                
            } else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "ImgTxtCellIdentifier")
                guard let _ = cell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Error Cell")
                }
                cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                (cell as! KTSettingsImgTextTableViewCell).lblText.text = "strRateApp".localized()
                (cell as! KTSettingsImgTextTableViewCell).imgIcon.image = UIImage(named: "SettingIconRate")
                (cell as! KTSettingsImgTextTableViewCell).otpSwitch.isHidden = true
                (cell as! KTSettingsImgTextTableViewCell).detailText.isHidden = true

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
                (cell as! KTSettingsImgTextTableViewCell).otpSwitch.isHidden = true

            }
        }
        
        
        return cell!
    }
    
    @objc func setOneTimePassword(sender: UIButton) {

        showProgressHud(show: true)
        KTUserManager().updateOTP(otp: otpEnabledStatus) { status, response in
            
            self.showToast(message: "profile_updated".localized())
            
            self.hideProgressHud()
            print(response)
            self.tableView.reloadData()
                        
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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
            if indexPath.row == 1{
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
            UserDefaults.standard.removeObject(forKey: "OTPEnabled")
            (self.viewModel as! KTSettingsViewModel).logout()
        }))
        
        logoutAlt.addAction(UIAlertAction(title: "cancel".localized(), style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(logoutAlt, animated: true, completion: nil)
    }
    
    

}
