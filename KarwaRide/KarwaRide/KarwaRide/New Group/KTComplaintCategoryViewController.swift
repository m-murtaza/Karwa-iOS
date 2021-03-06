//
//  KTComplaintCategoryViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/9/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import Spring

class KTComplaintCategoryViewController: KTBaseDrawerRootViewController,KTComplaintCategoryViewModelDelegate,UITableViewDelegate,UITableViewDataSource, KTLifeCycle
{

    @IBOutlet weak var tblView: UITableView!
    public var vModel : KTComplaintCategoryViewModel?

    @IBOutlet weak var btnComplaints: SpringButton!
    @IBOutlet weak var complaintSelector: UIImageView!
    
    @IBOutlet weak var btnLostItems: SpringButton!
    @IBOutlet weak var lostItemsSelector: UIImageView!
    @IBOutlet weak var footer: UIView!

    var bookingId = String()
    var shouldDismissOnLoad = false

    override func viewDidLoad()
    {
        self.viewModel = KTComplaintCategoryViewModel(del: self)
        vModel = viewModel as? KTComplaintCategoryViewModel
        vModel?.bookingId = bookingId
        tblView.dataSource = self
        tblView.delegate = self;

        print("Booking ID " + bookingId)
        
        super.viewDidLoad()
        self.tblView.rowHeight = 80
        self.tblView.tableFooterView = UIView()
        self.title = "complaintStrCapital".localized()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        if(shouldDismissOnLoad)
        {
            self.dismiss()
        }
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (vModel?.numberOfRows())!
    }
    
    @IBAction func btnBackTapped(_ sender: Any)
    {
        self.dismiss()
    }

    @IBAction func complaintTapped(_ sender: Any)
    {
        animationDelay = 0
        vModel?.complaintTapped()
    }
    @IBAction func lostItemsTapped(_ sender: Any)
    {
        animationDelay = 0
        vModel?.lostItemTapped()
    }
    
    func needsToDismiss(shouldDismiss: Bool)
    {
        shouldDismissOnLoad = shouldDismiss
    }
    
    var animationDelay = 1.0

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : KTComplaintsCategoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ComplaintCategoryTableViewCellIdentifier") as! KTComplaintsCategoryTableViewCell
        cell.labelTitle.text = vModel?.categoryName(forCellIdx: indexPath.row)
        cell.labelDesc.text = vModel?.description(forCellIdx: indexPath.row)
        cell.imageIcon.image = vModel?.notificationIcon(forCellIdx: indexPath.row)
        cell.selectionStyle = .none
        
        animateCell(cell, delay: animationDelay)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return UIView(frame: CGRect(x: 0, y: 0, width: 10 , height: 30))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        vModel?.rowSelected(atIndex: indexPath.row)
    }
    
    func reloadTableData()
    {
        tblView.reloadData()
    }

    func toggleTab(showSecondTab isComplaintsVisible : Bool)
    {
        btnComplaints.setTitleColor(isComplaintsVisible ? UIColor.gray : UIColor.init(hex: "#006170"), for: .normal)
        btnLostItems.setTitleColor(isComplaintsVisible ? UIColor.init(hex: "#006170") : UIColor.gray, for: .normal)
        lostItemsSelector.isHidden = !isComplaintsVisible
        complaintSelector.isHidden = isComplaintsVisible
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "segueCategoryToIssueSelection")
        {
            let navVC = segue.destination as? UINavigationController
            let destination = navVC?.viewControllers.first as! KTIssueSelectionViewController
            destination.previousControllerLifeCycle = self
            destination.bookingId = (vModel?.bookingId)!
            destination.categoryId = (vModel?.selectedCategory.id)!
            destination.complaintType = (vModel?.isComplaintsShowing)! ? 1 : 2
            destination.name = (vModel?.selectedCategory.title)!
        }
    }

    func showIssueSelectionScene()
    {
        self.performSegue(name: "segueCategoryToIssueSelection")
    }
}

