//
//  KTFarePopupViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/10/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTFarePopupViewModelDelegate: KTViewModelDelegate {
    func setTitleLable(title: String)
    func setTotalLabel(total: String)
    func setTitleTotalLabel(titalTotal : String)
    func reloadTable()
}

class KTFarePopupViewModel: KTBaseViewModel {
    var del : KTFarePopupViewModelDelegate?
    var headers : [KTKeyValue]?
    var body : [KTKeyValue]?
    //var title : String = ""
    //var total : String = ""
    
    override func viewDidLoad() {
        
        del = self.delegate as? KTFarePopupViewModelDelegate
    }
    
    
    func set(header h : [KTKeyValue]?, body b: [KTKeyValue]?, title: String, total: String,titleTotal: String)  {
        headers = h
        body = b
        del?.setTitleLable(title: title)
        del?.setTotalLabel(total: total)
        del?.setTitleTotalLabel(titalTotal : titleTotal )
        del?.reloadTable()
    }
    
    func numberOfSection() -> Int {
        var numSections : Int = 0
        if headers != nil && (headers?.count)! > 0 {
            numSections += 1
        }
        if body != nil && (body?.count)! > 0  {
            
            numSections += 1
        }
        return numSections
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        var numRow : Int = 0
        
        if section == 0 {
            if headers != nil && (headers?.count)! > 0 {
                numRow = (headers != nil) ? (headers?.count)! : 0
            }
            else {
                numRow = (body != nil) ? (body?.count)! : 0
            }
        }
        else {
            numRow = (body != nil) ? (body?.count)! : 0
        }
        
        return numRow
    }
    
    func key(forIndex idx: Int, section : Int) -> String {
        var k : String = ""
        if section == 0 {
            if headers != nil && (headers?.count)! > 0 {
                k = headers![idx].key!
            }
            else {
                k = body![idx].key!
            }
        }
        else {
            k = body![idx].key!
        }
        return k
    }
    
    func value(forIndex idx: Int, section : Int) -> String {
        var k : String = ""
        if section == 0 {
            if headers != nil && (headers?.count)! > 0 {
                k = headers![idx].value!
            }
            else {
                k = body![idx].value!
            }
        }
        else {
            k = body![idx].value!
        }
        return k
    }
}
