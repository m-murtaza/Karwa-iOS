
import UIKit
import Foundation

fileprivate var bottomConstraint : NSLayoutConstraint?
fileprivate var imageCompletion : ((UIImage?)->())?
fileprivate var constraintValue : CGFloat = 0

extension UIViewController {
    
    
    func showCustomAlert(title: String? = "", message:String?, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        for action in actions {
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- Pop or dismiss View Controller
    
    func popOrDismiss(animation : Bool){
        
        DispatchQueue.main.async {
            
            if self.navigationController != nil {
                
                self.navigationController?.popViewController(animated: animation)
            } else {
                
                self.dismiss(animated: animation, completion: nil)
            }
            
        }
        
    }
    
    //MARK:- Present
    
    func present(id : String, animation : Bool){
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: id){
            self.present(vc, animated: animation, completion: nil)
        }
        
    }
    
    //MARK:- Back Button Action
    
    @IBAction func backButtonClick() {
        self.popOrDismiss(animation: true)
    }
    
    /*
    //MARK:- Show Image Picker
    
    private func chooseImage(with source : UIImagePickerController.SourceType){
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = source
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    */
    
    /*  //MARK:- Right Bar Button Action
     
     @IBAction private func rightBarButtonAction(){
     
     let alertRightBar = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
     
     alertRightBar.addAction(UIAlertAction(title: Constants.string.newGroup, style: .default, handler: { (Void) in
     
     }))
     
     alertRightBar.addAction(UIAlertAction(title: Constants.string.newBroadcast, style: .default, handler: { (Void) in
     
     }))
     
     alertRightBar.addAction(UIAlertAction(title: Constants.string.starredMessages, style: .default, handler: { (Void) in
     
     }))
     
     alertRightBar.addAction(UIAlertAction(title: Constants.string.settings, style: .default, handler: { (Void) in
     
     self.pushRight(toViewController: self.storyboard!.instantiateViewController(withIdentifier: Storyboard.Ids.SettingViewController))
     
     }))
     
     alertRightBar.addAction(UIAlertAction(title: Constants.string.Cancel, style: .cancel, handler: { (Void) in
     
     }))
     
     alertRightBar.view.tintColor = .primary
     
     self.present(alertRightBar, animated: true, completion: nil)
     
     }  */
    
    
    //MARK:- Show Search Bar with self delegation
    
    @IBAction private func showSearchBar(){
        
        let searchBar = UISearchController(searchResultsController: nil)
        searchBar.searchBar.delegate = self as? UISearchBarDelegate
        searchBar.hidesNavigationBarDuringPresentation = false
        searchBar.dimsBackgroundDuringPresentation = false
        searchBar.searchBar.tintColor = .primary
        self.present(searchBar, animated: true, completion: nil)
        
    }
    
    
    
}

//MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate
/*
extension UIViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage {
                imageCompletion?(image)
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


*/


extension UIDevice {
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            // Fallback on earlier versions
        }
        
        return false
    }
}
