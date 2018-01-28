//
//  KTAddressPickerViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/23/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
enum SelectedTextField: Int {
    case PickupAddress = 1
    case DropoffAddress = 2
}
class KTAddressPickerViewController: KTBaseViewController,KTAddressPickerViewModelDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var txtPickAddress: UITextField!
    @IBOutlet weak var txtDropAddress: UITextField!
    
    private var selectedTxtField : SelectedTextField = SelectedTextField.DropoffAddress
    private var searchTimer: Timer = Timer()
    private var searchText : String = ""
    
    override func viewDidLoad() {
        viewModel = KTAddressPickerViewModel(del:self)
        super.viewDidLoad()
    }
    
    // MARK: - View Model Delegate
    func loadData() {
        tblView.reloadData()
        
    }
    
    // MARK: - TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTAddressPickerViewModel).numberOfRow()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AddressPickCell = tableView.dequeueReusableCell(withIdentifier: "AddPickCellIdentifier", for: indexPath) as! AddressPickCell
            /*AddressPickCell(style: UITableViewCellStyle.default, reuseIdentifier: "AddPickCellIdentifier")*/
        
        cell.addressTitle.text = (viewModel as! KTAddressPickerViewModel).addressTitle(forRow: indexPath.row)
        
        
        return cell
    }
    
    // MARK: - UItextField Delegates
    func textFieldDidBeginEditing(_ textField: UITextField){
        updateSelectedField(txt:textField)
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchText = textField.text!;
        if searchTimer.isValid {
            
            searchTimer.invalidate()
        }
        
        searchTimer = Timer.scheduledTimer(timeInterval: 3, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: false)
        
        return true;
    }
    
    @objc func updateTimer() {
        print("OK Start searching now")
        UIApplication.shared.beginIgnoringInteractionEvents()
        (viewModel as! KTAddressPickerViewModel).fetchLocations(forSearch: searchText)
    }
    func updateSelectedField(txt: UITextField) {
        
        if txt.isEqual(txtDropAddress) {
            searchText = txtDropAddress.text!
            selectedTxtField = SelectedTextField.DropoffAddress
        }
        else {
            searchText = txtPickAddress.text!
            selectedTxtField = SelectedTextField.PickupAddress
        }
    }
}

class AddressPickCell: UITableViewCell {
    @IBOutlet weak var addressTitle : UILabel!
}

