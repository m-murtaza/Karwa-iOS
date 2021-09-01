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

class KTXpressAddressViewController: KTBaseViewController, KTXpressAddressPickerViewModelDelegate, AddressPickerCellDelegate, KTXpressFavoriteDelegate {

    @IBOutlet weak var pickUpAddressHeaderLabel: SpringLabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: SpringButton!

    var fromPickup = false
    var fromDropOff = false

    var delegateAddress: KTXpressAddressDelegate?
    
    var vModel : KTXpressAddressPickerViewModel?
    var metroStations = [Area]()

    private var searchTimer: Timer = Timer()
    private var searchText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = KTXpressAddressPickerViewModel(del:self)
        vModel = viewModel as? KTXpressAddressPickerViewModel
        vModel?.metroStations = self.metroStations
        
        pickUpAddressHeaderLabel.text = fromDropOff ? "DROPOFFHEADER".localized() : "PICKUPHEADER".localized()
        
        pickUpAddressHeaderLabel.duration = 1
        pickUpAddressHeaderLabel.delay = 0.15
        pickUpAddressHeaderLabel.animation = "slideUp"
        pickUpAddressHeaderLabel.animate()
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        
//        pickUpAddressHeaderLabel.animation = "squeeze"
//        pickUpAddressHeaderLabel.animate()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor(hexString: "#F9F9F9")
        
        self.textField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        self.textField.becomeFirstResponder()
        
        self.textField.text = ""
        
        self.textField.placeholder = "str_search".localized()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tableView.keyboardDismissMode = .onDrag

                
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + tableView.rowHeight, right: 0)
            }
        }

        @objc private func keyboardWillHide(notification: NSNotification) {
            tableView.contentInset = .zero
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
            headerLabel.text = "favorites_title".localizedUppercase
        } else {
            headerLabel.text = "str_metro_title".localizedUppercase
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
        
        cell.moreButton.setImage((viewModel as! KTXpressAddressPickerViewModel).moreButtonIcon(forIndex: indexPath), for: .normal)
        
        cell.moreButton.addTarget(self, action: #selector(showActionSheet(sender:)), for: .touchUpInside)
        
        cell.moreButton.tag = indexPath.row
        cell.delegate = self
        
        return cell
        
    }
    
    @objc func showActionSheet(sender: UIButton) {
        guard let cell = sender.superview?.superview as? KTXpressAddressTableViewCell else {
            return // or fatalError() or whatever
        }
        
        let indexPath = tableView.indexPath(for: cell)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        let homeAction = UIAlertAction(title: "set_as_home_address".localized(), style: .default) { (UIAlertAction) in
            (self.viewModel as! KTXpressAddressPickerViewModel).setHome(forIndex: indexPath!)
        }
        let workAction = UIAlertAction(title: "set_as_work_address".localized(), style: .default) { (UIAlertAction) in
            (self.viewModel as! KTXpressAddressPickerViewModel).setWork(forIndex: indexPath!)
        }
        let favoriteAction = UIAlertAction(title: "set_as_favorite".localized(), style: .default) { (UIAlertAction) in
            (self.viewModel as! KTXpressAddressPickerViewModel).setFavorite(forIndex: indexPath!)
        }
        
        alertController.addAction(cancelAction)
        
        if let location = (self.viewModel as! KTXpressAddressPickerViewModel).locationAtIndexPath(indexPath: indexPath!) as? KTGeoLocation {
            if location.type == geoLocationType.Home.rawValue {
                alertController.addAction(workAction)
                alertController.addAction(favoriteAction)
            }
            else if location.type == geoLocationType.Work.rawValue {
                alertController.addAction(homeAction)
                alertController.addAction(favoriteAction)
            }else if location.type == geoLocationType.favorite.rawValue {
                alertController.addAction(homeAction)
                alertController.addAction(workAction)
            }
            else {
                alertController.addAction(homeAction)
                alertController.addAction(workAction)
                alertController.addAction(favoriteAction)
            }
            alertController.modalTransitionStyle = .crossDissolve
            self.present(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    func toGeolocation(area: Area) -> KTGeoLocation {
        let location = KTGeoLocation(context: NSManagedObjectContext.mr_default())
        location.area = metroStations.first?.name
        
        let coordinates = (area.bound?.components(separatedBy: ";").map{$0.components(separatedBy: ",")}.map{$0.map({Double($0)!})}.map { (value) -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(latitude: value[0], longitude: value[1])
        })!
        location.latitude = coordinates.first!.latitude
        location.longitude = coordinates.first!.longitude
        location.name = area.name
        location.locationId = Int32((area.code)!)
        location.type = 0
        location.favoriteName = area.name ?? ""
        return location
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegateAddress?.setLocation(location: (self.viewModel as! KTXpressAddressPickerViewModel).locationAtIndexPath(indexPath: indexPath))
        self.navigationController?.popViewController(animated: true)
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
        let vc = KTXpressFavoriteAddressViewController()
        vc.favoritelocation = location
        vc.xpressFavoriteDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func btnMoreTapped(withTag idx: Int) {
        
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
    func savedFavorite() {
        (viewModel as! KTXpressAddressPickerViewModel).fetchLocations()
    }
}



class KTXpressAddressTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    var delegate : AddressPickerCellDelegate?

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
    
    @IBAction func btnMoreTapped(_ sender: Any) {
        
        //TODO: Show action sheet. As discussed with Danish bahi
        self.delegate?.btnMoreTapped(withTag: moreButton.tag)
    }
    
}

