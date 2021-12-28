//
//  KTUserManager+ForgotPass.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/11/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

extension KTUserManager
{
    func sendForgotPassRequest(countryCode: String, phone: String, password: String,completion completionBlock:@escaping KTDALCompletionBlock)
    {
        let param : [String : Any] = [Constants.UpdatePassParam.Phone : phone,
                                      Constants.LoginParams.CountryCode : countryCode,
                                           Constants.UpdatePassParam.Password: password]
        
        self.post(url: Constants.APIURL.ForgotPasswordNew, param: param, completion: completionBlock) { (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS, response)
        }
        
    }
    
    func sendForgotPassRequest(countryCode: String, phone: String, password: String, email: String, completion completionBlock:@escaping KTDALCompletionBlock)
    {
        let param : [String : Any] = [Constants.UpdatePassParam.Phone : phone,
                                      Constants.LoginParams.CountryCode : countryCode,
                                      Constants.UpdatePassParam.Password: password,
                                      Constants.EditAccountInfoParam.Email: email]
        
        self.post(url: Constants.APIURL.ForgotPass, param: param, completion: completionBlock) { (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS, response)
        }
        
    }
        
    func verifyChallenge(countryCode: String, phone: String, challenge: String, challengeType: String, challengeAnswer: String, completion completionBlock:@escaping KTDALCompletionBlock)
    {
        let param : [String : Any] = [Constants.VerifyChallengeParams.Phone : countryCode+phone,
                                      Constants.VerifyChallengeParams.challenge : challenge,
                                      Constants.VerifyChallengeParams.challengeType: challengeType,
                                      Constants.VerifyChallengeParams.challengeAnswer: challengeAnswer]
        
        self.post(url: Constants.APIURL.verifyChallenge, param: param, completion: completionBlock) { (response, cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS, response)
        }
        
    }
}
