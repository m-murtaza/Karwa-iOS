//
//  KTIssueSelectionViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/10/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTIssueSelectionViewController: KTBaseDrawerRootViewController,KTIssueSelectionViewModelDelegate,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var commentsInput: UITextField!
    
    private var vModel : KTIssueSelectionViewModel?
    
    var complaint = KTComplaint()
    
    override func viewDidLoad()
    {
        self.viewModel = KTIssueSelectionViewModel(del: self)
        vModel = viewModel as? KTIssueSelectionViewModel
        tbleView.dataSource = self
        super.viewDidLoad()
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (vModel?.numberOfRows())!
    }
   
    var animationDelay = 1.0
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : KTIssueTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KTIssueTableViewCellIdentifier") as! KTIssueTableViewCell
        cell.issueName.text = vModel?.categoryName(forCellIdx: indexPath.row)
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
        tbleView.reloadData()
    }
}

