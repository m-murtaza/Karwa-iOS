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
}
