//
//  KTIssueSelectionViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/10/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Spring

class KTIssueSelectionViewController: KTBaseDrawerRootViewController,KTIssueSelectionViewModelDelegate,UITableViewDelegate,UITableViewDataSource, UITextViewDelegate
{
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var titleText: SpringLabel!
    @IBOutlet weak var commentsLabel: SpringTextView!
    @IBOutlet weak var btnSubmit: SpringButton!
    
    var previousControllerLifeCycle : KTLifeCycle!
    
    private var vModel : KTIssueSelectionViewModel?
    
    var bookingId = String()
    var categoryId = -1
    var complaintType = 1
    var name = String()
    
    override func viewDidLoad()
    {
        self.viewModel = KTIssueSelectionViewModel(del: self)
        vModel = viewModel as? KTIssueSelectionViewModel
        
        vModel?.bookingId = bookingId
        vModel?.categoryId = categoryId
        vModel?.complaintType = complaintType

        super.viewDidLoad()
        self.title = name
        commentsLabel.delegate = self
        initTableView()
    }
    
    func initTableView()
    {
        self.tbleView.rowHeight = 65
        self.tbleView.tableFooterView = UIView()
        self.tbleView.allowsSelection = true
        self.tbleView.delegate = self
        tbleView.dataSource = self
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n")
        {
            commentsLabel.resignFirstResponder()
            
            let input: String = commentsLabel.text!
            vModel?.submitBtnTapped(remarksString: input)
            
            return false
        }
        return true
    }
    
    @IBAction func submutTouchDown(_ sender: Any)
    {
        springAnimateButtonTapIn(button: btnSubmit)
    }
    
    @IBAction func btnBackTapped(_ sender: Any)
    {
        self.dismiss()
    }

    @IBAction func btnSubmitTapped(_ sender: Any)
    {
        springAnimateButtonTapOut(button: btnSubmit)

        commentsLabel.resignFirstResponder()
        
        let input: String = commentsLabel.text!
        vModel?.submitBtnTapped(remarksString: input)
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
    
    func showMessage(_ title: String, _ message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.dismissWithResult()
        }
        
        //alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showInputRemarksLayout()
    {
        UIView.animate(withDuration: 0.75, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            if self.tbleView?.alpha == 1.0
                { self.tbleView?.alpha = 0.0 }
            else
                { self.tbleView?.alpha = 1.0 }
        }, completion: { (finished:Bool) -> Void in self.tbleView.isHidden = true })

        titleText.isHidden = false
        commentsLabel.isHidden = false
        btnSubmit.isHidden = false

        titleText.animation = "squeezeLeft"
        commentsLabel.animation = "squeezeLeft"
        btnSubmit.animation = "squeezeLeft"
        titleText.delay = 0.2
        commentsLabel.delay = 0.2
        btnSubmit.delay = 0.2

        titleText.animate()
        commentsLabel.animate()
        btnSubmit.animate()
        
        commentsLabel.becomeFirstResponder()
    }
    
    func hideInputRemarksLayout()
    {
        tbleView.isHidden = false
        titleText.isHidden = true
        commentsLabel.isHidden = true
        btnSubmit.isHidden = true
    }
    
    func dismissWithResult()
    {
        previousControllerLifeCycle.needsToDismiss(shouldDismiss: true)
        self.dismiss()
    }
}

