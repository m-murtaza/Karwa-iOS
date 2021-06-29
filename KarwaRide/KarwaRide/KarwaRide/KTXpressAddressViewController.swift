//
//  KTXpressPickUpViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 14/05/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import GoogleMaps
import Spring

class KTXpressAddressViewController: KTBaseViewController, KTXpressAddressPickerViewModelDelegate {

    @IBOutlet weak var pickUpAddressHeaderLabel: SpringLabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: SpringButton!

    var fromPickup: Bool?
    var fromDropOff: Bool?

    var vModel : KTXpressAddressPickerViewModel?
    var metroStations = [Area]()

    private var searchTimer: Timer = Timer()
    private var searchText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = KTXpressAddressPickerViewModel(del:self)
        vModel = viewModel as? KTXpressAddressPickerViewModel
        vModel?.metroStations = self.metroStations

        pickUpAddressHeaderLabel.duration = 1
        pickUpAddressHeaderLabel.delay = 0.15
        pickUpAddressHeaderLabel.animation = "slideUp"
        pickUpAddressHeaderLabel.animate()
        
//        pickUpAddressHeaderLabel.animation = "squeeze"
//        pickUpAddressHeaderLabel.animate()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor(hexString: "#F9F9F9")
        
        self.textField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        self.textField.becomeFirstResponder()
        
        self.textField.text = ""
        
        self.textField.placeholder = "Search for location".localized()
                
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension KTXpressAddressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50))
        sectionHeaderView.backgroundColor = UIColor(hexString: "#F9F9F9")
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.tableView.frame.width, height: 30))
        
        if section == 0 {
            return nil
        } else if section == 1 {
            headerLabel.text = "favorites_title".localized().capitalized
        } else {
            headerLabel.text = "str_metro_title".localized().capitalized
        }
      
        headerLabel.textColor = UIColor(hexString: "#8EA8A7")
        headerLabel.font = UIFont(name: "MuseoSans-500", size: 10.0)!
        sectionHeaderView.addSubview(headerLabel)
        
        return sectionHeaderView
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTXpressAddressPickerViewModel).numberOfRow(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : KTXpressAddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KTXpressAddressTableViewCell") as! KTXpressAddressTableViewCell
        cell.backgroundColor = UIColor(hexString: "#F9F9F9")

        cell.titleLabel.text = (viewModel as! KTXpressAddressPickerViewModel).addressTitle(forIndex: indexPath)
        cell.addressLabel.text = (viewModel as! KTXpressAddressPickerViewModel).addressArea(forIndex: indexPath)
        cell.icon.image = (viewModel as! KTXpressAddressPickerViewModel).addressTypeIcon(forIndex: indexPath)
        
        cell.moreButton.tag = indexPath.row
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadData() {
        self.tableView.reloadData()
    }
    
    func pickUpTxt() -> String {
        return self.textField.text!
    }
    
    func dropOffTxt() -> String {
        return self.textField.text!
    }
    
    func setPickUp(pick: String) {
        self.textField.text = pick
    }
    
    func setDropOff(drop: String) {
        self.textField.text = drop
    }
    
    func navigateToPreviousView(pickup: KTGeoLocation?, dropOff: KTGeoLocation?) {
        
    }
    
    func inFocusTextField() -> SelectedTextField {
        return .PickupAddress
    }
    
    func moveFocusToDestination() {
        
    }
    
    func moveFocusToPickUp() {
        
    }
    
    func getConfirmPickupFlowDone() -> Bool {
     return true
    }
    
    func setConfirmPickupFlowDone(isConfirmPickupFlowDone: Bool) {
        
    }
    
    func startConfirmPickupFlow() {
        
    }
    
    func toggleConfirmBtn(enableBtn enable: Bool) {
        
    }
    
    func navigateToFavoriteScreen(location: KTGeoLocation?) {
        
    }
    
    
}

extension KTXpressAddressViewController:  UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      textField.superview?.addExternalBorder(borderWidth: 2.0,
                                             borderColor: UIColor.primary,
                                             cornerRadius: 8.0)
      textField.superview?.backgroundColor = UIColor.white
      return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
      
      textField.text = (viewModel as! KTXpressAddressPickerViewModel).pickUpAddress?.name
      
      textField.superview?.removeExternalBorders()
      textField.superview?.backgroundColor = UIColor.clear
      return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
      //print("---textFieldDidEndEditing---")
//      clearButtonPickup.isHidden = true
//      clearButtonDestination.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

      searchText = textField.text!;
      if searchTimer.isValid {
        
        searchTimer.invalidate()
      }
      if let txt = textField.text, txt.count >= MIN_ALLOWED_TEXT_COUNT_SEARCH {
        searchTimer = Timer.scheduledTimer(timeInterval: SEC_WAIT_START_SEARCH, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: false)
      }
      
      return true;
    }
    
    
    @objc func updateTimer() {
      print("OK Start searching now")
      
        (viewModel as! KTXpressAddressPickerViewModel).fetchLocations(forSearch: searchText)
      
    }
}



class KTXpressAddressTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var moreButton: UIButton!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

