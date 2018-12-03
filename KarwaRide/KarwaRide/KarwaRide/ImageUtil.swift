//
//  ImageUtil.swift
//  KarwaRide
//
//  Created by Sam Ash on 11/12/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

class ImageUtil
{
    static func getImage(_ brand: String) -> String
    {
        var brandImage = "ico_wallet"
        
        switch brand
        {
        case "MASTERCARD":
            brandImage = "ico_mc"
            break;
        case "MASTER":
            brandImage = "ico_mc"
            break;
        case "VISACARD":
            brandImage = "ico_visa"
            break;
        case "VISA":
            brandImage = "ico_visa"
            break;
        case "AMEXCARD":
            brandImage = "ico_amex"
            break;
        case "AMEX":
            brandImage = "ico_amex"
            break;
        case "DINERSCLUBCARD":
            brandImage = "ico_dinersclub"
            break;
        case "DINERS_CLUB":
            brandImage = "ico_dinersclub"
            break;
        case "DISCOVERCARD":
            brandImage = "ico_discover"
            break;
        case "DISCOVER":
            brandImage = "ico_discover"
            break;
        case "JCBCARD":
            brandImage = "ico_jcb"
            break;
        case "JCB":
            brandImage = "ico_jcb"
            break;
        case "MAESTROCARD":
            brandImage = "ico_maestro"
            break;
        case "MAESTRO":
            brandImage = "ico_maestro"
            break;
        case "Cash":
            brandImage = "BDIconCash"
            break;
        case "":
            brandImage = "BDIconCash"
            break;
        default:
            brandImage = "ico_wallet"
            break;
        }
        return brandImage
    }
    
    static func getSmallImage(_ brand: String) -> String
    {
        var brandImage = "wallet_ico_sm"
        
        switch brand
        {
        case "MASTERCARD":
            brandImage = "mastercard_ico_sm"
            break;
        case "MASTER":
            brandImage = "mastercard_ico_sm"
            break;
        case "VISACARD":
            brandImage = "visa_ico_sm"
            break;
        case "VISA":
            brandImage = "visa_ico_sm"
            break;
        case "AMEXCARD":
            brandImage = "amex_ico_sm"
            break;
        case "AMEX":
            brandImage = "amex_ico_sm"
            break;
        case "DINERSCLUBCARD":
            brandImage = "dinersclub_ico_sm"
            break;
        case "DINERS_CLUB":
            brandImage = "dinersclub_ico_sm"
            break;
        case "DISCOVERCARD":
            brandImage = "discover_ico_sm"
            break;
        case "DISCOVER":
            brandImage = "discover_ico_sm"
            break;
        case "JCBCARD":
            brandImage = "jcb_ico_sm"
            break;
        case "JCB":
            brandImage = "jcb_ico_sm"
            break;
        case "MAESTROCARD":
            brandImage = "maestro_ico_sm"
            break;
        case "MAESTRO":
            brandImage = "maestro_ico_sm"
            break;
        case "Cash":
            brandImage = "BDIconCash"
            break;
        case "":
            brandImage = "BDIconCash"
            break;
        default:
            brandImage = "wallet_ico_sm"
            break;
        }
        return brandImage
    }
}