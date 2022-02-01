//
//  KTKarwaBusPlanTripViewController.swift
//  KarwaRide
//
//  Created by Apple on 30/01/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import Spring


class KTKarwaBusPlanTripViewController: KTBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var vModel : KTKarwaPlanTripViewmodel?
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pickAddressLabel: UILabel!
    @IBOutlet weak var dropAddressLabel: UILabel!
    @IBOutlet weak var departArriveButton: SpringButton!

    private lazy var datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .time
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var toolBar : UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneClicked))]
        toolBar.sizeToFit()
        return toolBar
    }()
    
    override func viewDidLoad() {
        viewModel = KTKarwaPlanTripViewmodel(del:self)
        vModel = viewModel as? KTKarwaPlanTripViewmodel
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 15.0, *) {
            self.tblView.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func setPickupTapped(_ sender: Any) {
        (viewModel as! KTKarwaPlanTripViewmodel).btnPickupAddTapped()
    }
    
    @IBAction func setDropOffTapped(_ sender: Any) {
        (viewModel as! KTKarwaPlanTripViewmodel).btnDropAddTapped()
    }
    
    @IBAction private func swapAddress() {
//        let temporary = pickUpAddress
//        pickUpAddress = dropOffAddress
//        dropOffAddress = temporary
//
//        if txtPickAddress.text!.isEmpty && txtDropAddress.text!.isEmpty {
//         return
//        }
//        let result = (viewModel as! KTAddressPickerViewModel).swapPickupAndDestination()
//        if result {
//          let temporary = txtPickAddress.text!
//          txtPickAddress.text = txtDropAddress.text!
//          txtDropAddress.text = temporary
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination : KTAddressPickerViewController = segue.destination as! KTAddressPickerViewController
        destination.previousNewView = (viewModel as! KTKarwaPlanTripViewmodel)
        if segue.identifier == "seguePlanTripToDropOffAddress" {
          destination.selectedTxtField = SelectedTextField.DropoffAddress
        }
        else {
          destination.selectedTxtField = SelectedTextField.PickupAddress
        }
    }
        
    @IBAction func addDatePicker(_ sender: UIButton) {
        self.view.addSubview(self.datePicker)
        self.view.addSubview(self.toolBar)
        
        NSLayoutConstraint.activate([
            self.datePicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.datePicker.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.datePicker.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.datePicker.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        NSLayoutConstraint.activate([
            self.toolBar.bottomAnchor.constraint(equalTo: self.datePicker.topAnchor),
            self.toolBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.toolBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.toolBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func onDoneClicked(picker : UIDatePicker) {
        self.toolBar.removeFromSuperview()
        self.datePicker.removeFromSuperview()
    }
    
    @objc private func dateChanged(picker : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        print("Picked the date \(dateFormatter.string(from: picker.date))")
        self.departArriveButton.setTitle("Depart at \(dateFormatter.string(from: picker.date))", for: .normal)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        headerLabel.text = "Suggested Routes"
        headerLabel.font = UIFont(name: "MuseoSans-900", size: 14.0)
        headerLabel.textColor = .lightText
        return headerLabel
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : KarwaPlanTripTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KarwaPlanTripTableViewCell") as! KarwaPlanTripTableViewCell
        cell.selectionStyle = .none
        
        cell.legsScrollView.isUserInteractionEnabled = false
        cell.contentView.addGestureRecognizer(cell.legsScrollView.panGestureRecognizer)
        
        return cell
    }
    
    
}

class KarwaPlanTripTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var legsStackView: UIStackView!
    @IBOutlet weak var legsScrollView: UIScrollView!
    
    var legs: [Leg]? {
        didSet {
            setUpUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpUI()
    }

    func setUpUI() {
                
        for i in 0..<5 {
            
            let imageView = UIImageView()
            imageView.heightAnchor.constraint(equalToConstant: 5.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 8.0).isActive = true
            imageView.image = UIImage(named: "icon-trips-right-arrow")
            imageView.contentMode = .center

            //Text Label
            let textLabel = PaddingLabel()
            textLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
            textLabel.addLeading(image: UIImage(named: "BusListing")!, text: "20", imageOffsetY: -2)
            textLabel.textAlignment = .center
            textLabel.font =  UIFont(name: "MuseoSans-500", size: 12.0)
            textLabel.customBorderWidth = 1
            textLabel.customBorderColor = .primary
            textLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            textLabel.customCornerRadius = 3
            legsStackView.addArrangedSubview(textLabel)
            legsStackView.addArrangedSubview(imageView)
            legsScrollView.contentSize = CGSize(width: 5 * 100, height: 20.0)

            if i == 4 {
                imageView.isHidden = true
            }

        }
        
        self.layoutSubviews()
        
    }
    
    override func layoutSubviews() {
        legsScrollView.contentSize = CGSize(width: 5 * 100, height: 20.0)
        legsStackView.layoutSubviews()
        legsStackView.layoutIfNeeded()
    }
    
}


class KTBookKarwaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var legsStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
