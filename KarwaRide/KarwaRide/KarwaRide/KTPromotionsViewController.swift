//
//  PromotionsViewController.swift
//  KarwaRide
//
//  Created by Piecyfer on 17/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import CDAlertView

class KTPromotionsViewController: KTBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var vModel : KTPromotionsViewModel?
    private let refreshControl = UIRefreshControl()
    
    private var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        if viewModel == nil
        {
            viewModel = KTPromotionsViewModel(del: self)
        }
        vModel = viewModel as? KTPromotionsViewModel
        super.viewDidLoad()
        
        setupView()
        setupTBL()
        addMenuButton()
    }
    
    private func setupView() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor(hexString:"#006170"),
                                                                   NSAttributedStringKey.font : UIFont.init(name: "MuseoSans-900", size: 17)!]
        title = "str_promotions".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vModel?.fetchPromotions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(hexString:"#E5F5F2")
            appearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor(hexString:"#006170"),
                                              NSAttributedStringKey.font : UIFont.init(name: "MuseoSans-900", size: 17)!];
            self.navigationController?.navigationBar.standardAppearance = appearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        } else {
        }
    }
    
    func showNavigationController() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(hexString:"#E5F5F2")
            appearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor(hexString:"#006170"),
                                              NSAttributedStringKey.font : UIFont.init(name: "MuseoSans-900", size: 17)!];
            self.navigationController?.navigationBar.standardAppearance = appearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        } else {
        }
    }
    
    @objc func refresh(sender:AnyObject){
        (viewModel as! KTPromotionsViewModel).fetchPromotions()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showAlert(message: String) {
        let alert = CDAlertView(title: message, message: "", type: .custom(image: UIImage(named:"icon-notifications")!))
        alert.hideAnimations = { (center, transform, alpha) in
            alpha = 0
        }
        let doneAction = CDAlertViewAction(title: "str_ok".localized()) { value in
            return true
        }
        
        alert.add(action: doneAction)
        alert.show()
    }
}

extension KTPromotionsViewController: KTPromotionsViewModelDelegate {
    func reloadTable() {
        tableView.reloadData()
    }
    
    func showEmptyMessage(message: String) {
//        tableView.isHidden = true
    }
    
    func endRefreshing(){
        refreshControl.endRefreshing()
    }
}

extension KTPromotionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTPromotionsViewModel).numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: KTPromotionCell = tableView.dequeueReusableCell(withIdentifier: String(describing: KTPromotionCell.self)) as! KTPromotionCell
        var isSelected = false
        if let selectedIndex = self.selectedIndex, selectedIndex == indexPath {
            isSelected = true
        }
        cell.isShowMore = vModel!.getShowMore(at: indexPath.row)
        cell.index = indexPath
        cell.configCell(isSelected: isSelected, data: vModel!.getPromotion(at: indexPath.row))
        cell.onClickShowMore = { [weak self] (isShowMore, index) in
            guard let `self` = self else {return}
            self.vModel?.setShowMore(at: index.row, value: !isShowMore)
            self.selectedIndex = index
            self.tableView.reloadData()
        }
        cell.selectionStyle = .none
        animateCell(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        self.vModel?.setShowMore(at: indexPath.row, value: true)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    private func setupTBL(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: String(describing: KTPromotionCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: KTPromotionCell.self))
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        }
    }
}
