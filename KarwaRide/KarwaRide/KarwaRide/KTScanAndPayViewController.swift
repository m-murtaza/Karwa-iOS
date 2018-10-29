//
//  KTScanAndPayViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/29/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import BarcodeScanner

class KTScanAndPayViewController: KTBaseDrawerRootViewController,KTScanAndPayViewModelDelegate
{
    public var vModel : KTScanAndPayViewModel?
    
    override func viewDidLoad()
    {
        self.viewModel = KTScanAndPayViewModel(del: self)
        vModel = viewModel as? KTScanAndPayViewModel
        
        super.viewDidLoad()
        
        handleScanPresent()
    }
    
    private func handleScanPresent()
    {
        let viewController = makeBarcodeScannerViewController()
        viewController.title = "Barcode Scanner"
        present(viewController, animated: true, completion: nil)
    }
    
    private func handlePushScan()
    {
        let viewController = makeBarcodeScannerViewController()
        viewController.title = "Barcode Scanner"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
//        if(segue.identifier == "segueCategoryToIssueSelection")
//        {
//            let navVC = segue.destination as? UINavigationController
//            let destination = navVC?.viewControllers.first as! KTIssueSelectionViewController
//            destination.previousControllerLifeCycle = self
//            destination.bookingId = (vModel?.bookingId)!
//            destination.categoryId = (vModel?.selectedCategory.id)!
//            destination.complaintType = (vModel?.isComplaintsShowing)! ? 1 : 2
//            destination.name = (vModel?.selectedCategory.title)!
//        }
    }
    
//    func showIssueSelectionScene()
//    {
//        self.performSegue(name: "segueCategoryToIssueSelection")
//    }
    
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController
    {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        return viewController
    }
    
    func reloadTableData()
    {
    }
    
    func showIssueSelectionScene()
    {
    }
    
    func toggleTab(showSecondTab isComplaintsVisible: Bool)
    {
    }
}

    // MARK: - BarcodeScannerCodeDelegate
    extension KTScanAndPayViewController: BarcodeScannerCodeDelegate {
        func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
            print("Barcode Data: \(code)")
            print("Symbology Type: \(type)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                controller.resetWithError()
            }
        }
    }

    // MARK: - BarcodeScannerErrorDelegate
    extension KTScanAndPayViewController: BarcodeScannerErrorDelegate {
        func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
            print(error)
        }
    }

    // MARK: - BarcodeScannerDismissalDelegate
    extension KTScanAndPayViewController: BarcodeScannerDismissalDelegate
    {
        func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
            controller.dismiss(animated: true, completion: nil)
    }
}

